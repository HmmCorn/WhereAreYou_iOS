#!/usr/bin/env python3
"""
라벨 기반 AI 코드 리뷰 스크립트.

환경변수:
  GITHUB_TOKEN      - PR 조회/리뷰 등록용 토큰 (secrets.GITHUB_TOKEN)
  ANTHROPIC_API_KEY - Claude API 키 (secrets.ANTHROPIC_API_KEY)
  ANTHROPIC_MODEL   - 사용할 모델 이름 (기본값 아래 참고)
  REPO              - "owner/repo" 형식
  PR_NUMBER         - PR 번호
  ASPECT            - bug | performance | architecture | summary
"""

import json
import os
import re
import sys
import urllib.request
import urllib.error

GITHUB_API = "https://api.github.com"
ANTHROPIC_API = "https://api.anthropic.com/v1/messages"

# 실행 시점 기준 최신 모델을 secrets/vars의 ANTHROPIC_MODEL로 덮어쓸 수 있음.
DEFAULT_MODEL = "claude-sonnet-4-5-20250929"

MAX_PATCH_CHARS_PER_FILE = 6000  # 파일 하나의 diff가 너무 크면 잘라서 전송


def gh_request(method, path, token, body=None):
    url = f"{GITHUB_API}{path}"
    data = json.dumps(body).encode("utf-8") if body is not None else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Authorization", f"Bearer {token}")
    req.add_header("Accept", "application/vnd.github+json")
    req.add_header("X-GitHub-Api-Version", "2022-11-28")
    if data is not None:
        req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req) as resp:
            return json.loads(resp.read().decode("utf-8")) if resp.length != 0 else {}
    except urllib.error.HTTPError as e:
        print(f"[GitHub API 오류] {method} {path} -> {e.code}: {e.read().decode('utf-8')}", file=sys.stderr)
        raise


def fetch_pr_files(repo, pr_number, token):
    files = []
    page = 1
    while True:
        chunk = gh_request(
            "GET",
            f"/repos/{repo}/pulls/{pr_number}/files?per_page=100&page={page}",
            token,
        )
        if not chunk:
            break
        files.extend(chunk)
        if len(chunk) < 100:
            break
        page += 1
    return files


def annotate_patch(filename, patch):
    """
    GitHub의 patch(unified diff 일부)를 파싱해서 각 라인 앞에
    RIGHT:<번호> / LEFT:<번호> 태그를 붙인다. 모델이 정확한 라인 번호를
    그대로 인용할 수 있게 하기 위함.
    """
    if not patch:
        return f"### {filename}\n(바이너리 파일이거나 patch 없음 - 리뷰 대상에서 제외)\n"

    lines = patch.split("\n")
    out = [f"### {filename}"]
    right_line = left_line = 0

    for line in lines:
        m = re.match(r"^@@ -(\d+)(?:,\d+)? \+(\d+)(?:,\d+)? @@", line)
        if m:
            left_line = int(m.group(1))
            right_line = int(m.group(2))
            out.append(line)
            continue

        if line.startswith("+"):
            out.append(f"[RIGHT:{right_line}] {line}")
            right_line += 1
        elif line.startswith("-"):
            out.append(f"[LEFT:{left_line}] {line}")
            left_line += 1
        else:
            out.append(f"[RIGHT:{right_line}/LEFT:{left_line}] {line}")
            right_line += 1
            left_line += 1

    text = "\n".join(out)
    if len(text) > MAX_PATCH_CHARS_PER_FILE:
        text = text[:MAX_PATCH_CHARS_PER_FILE] + "\n... (파일이 길어 이하 생략됨)"
    return text


def build_diff_text(files):
    blocks = []
    for f in files:
        blocks.append(annotate_patch(f["filename"], f.get("patch")))
    return "\n\n".join(blocks)


def load_prompt(aspect):
    base_dir = os.path.join(os.path.dirname(__file__), "..", "prompts")
    with open(os.path.join(base_dir, "common.md"), encoding="utf-8") as f:
        common = f.read()
    with open(os.path.join(base_dir, f"{aspect}.md"), encoding="utf-8") as f:
        specific = f.read()
    return f"{common}\n\n{specific}"


def call_claude(system_prompt, diff_text, api_key, model):
    body = {
        "model": model,
        "max_tokens": 4000,
        "system": system_prompt,
        "messages": [
            {
                "role": "user",
                "content": (
                    "아래는 이번 PR의 diff다. 각 라인 앞의 [RIGHT:번호] / [LEFT:번호] 표기를 "
                    "그대로 활용해서 정확한 라인 번호로 코멘트를 남겨라.\n\n" + diff_text
                ),
            }
        ],
    }
    req = urllib.request.Request(
        ANTHROPIC_API,
        data=json.dumps(body).encode("utf-8"),
        method="POST",
    )
    req.add_header("x-api-key", api_key)
    req.add_header("anthropic-version", "2023-06-01")
    req.add_header("Content-Type", "application/json")

    with urllib.request.urlopen(req) as resp:
        data = json.loads(resp.read().decode("utf-8"))

    text_parts = [block["text"] for block in data.get("content", []) if block.get("type") == "text"]
    return "".join(text_parts)


def parse_model_json(raw_text):
    cleaned = raw_text.strip()
    cleaned = re.sub(r"^```(json)?", "", cleaned).strip()
    cleaned = re.sub(r"```$", "", cleaned).strip()
    return json.loads(cleaned)


def post_review(repo, pr_number, token, summary, comments, aspect):
    aspect_label = {
        "bug": "버그",
        "performance": "성능/최적화",
        "architecture": "아키텍처",
        "summary": "종합(핵심)",
    }.get(aspect, aspect)

    body = f"## 🤖 AI 코드 리뷰 - {aspect_label} 관점\n\n{summary}"

    review_comments = []
    for c in comments:
        review_comments.append(
            {
                "path": c["file"],
                "line": c["line"],
                "side": c.get("side", "RIGHT"),
                "body": f"**[{c.get('severity', 'medium').upper()}]** {c['body']}",
            }
        )

    payload = {
        "body": body,
        "event": "COMMENT",
    }
    if review_comments:
        payload["comments"] = review_comments

    try:
        gh_request("POST", f"/repos/{repo}/pulls/{pr_number}/reviews", token, payload)
    except urllib.error.HTTPError:
        # 라인 코멘트 등록이 실패하면(예: outdated diff 위치 문제) 요약만이라도 남긴다.
        print("라인 코멘트 등록 실패, 요약만 이슈 코멘트로 등록 시도", file=sys.stderr)
        gh_request(
            "POST",
            f"/repos/{repo}/issues/{pr_number}/comments",
            token,
            {"body": body + "\n\n(일부 라인 코멘트 등록에 실패해 요약만 표시됩니다.)"},
        )


def main():
    token = os.environ["GITHUB_TOKEN"]
    api_key = os.environ["ANTHROPIC_API_KEY"]
    model = os.environ.get("ANTHROPIC_MODEL", DEFAULT_MODEL)
    repo = os.environ["REPO"]
    pr_number = os.environ["PR_NUMBER"]
    aspect = os.environ["ASPECT"]

    files = fetch_pr_files(repo, pr_number, token)
    if not files:
        print("변경된 파일이 없어 리뷰를 건너뜁니다.")
        return

    diff_text = build_diff_text(files)
    system_prompt = load_prompt(aspect)

    raw = call_claude(system_prompt, diff_text, api_key, model)
    try:
        result = parse_model_json(raw)
    except json.JSONDecodeError:
        print("모델 응답 JSON 파싱 실패, 원문:", raw, file=sys.stderr)
        raise

    summary = result.get("summary", "").strip()
    comments = result.get("comments", [])

    post_review(repo, pr_number, token, summary, comments, aspect)
    print(f"[{aspect}] 리뷰 등록 완료. 코멘트 {len(comments)}개.")


if __name__ == "__main__":
    main()
