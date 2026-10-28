/**
 * 약속 생성·참여·나가기 callable 함수.
 * 참여 전 사용자는 약속 문서를 읽을 수 없고 코드 고유성을 보장해야 해서 서버가 처리한다.
 * 조회·정보 수정·내 경로 저장은 클라이언트가 Firestore에 직접 한다.
 *
 * 코드 고유성은 appointmentCodes/{code} 예약 문서로 보장한다 — 문서 ID가 코드라 같은 코드는 하나만 존재할 수 있다.
 * 예약 문서는 서버만 읽고 쓴다 (클라이언트 접근 없음).
 */

const {randomInt} = require("node:crypto");
const {setGlobalOptions} = require("firebase-functions");
const {onCall, HttpsError} = require("firebase-functions/https");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, FieldValue, Timestamp} = require("firebase-admin/firestore");

initializeApp();
const db = getFirestore();

// Firestore와 같은 서울 리전에 둔다
setGlobalOptions({region: "asia-northeast3", maxInstances: 10});

// 헷갈리는 0/O, 1/I를 뺀 32자
const CODE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
const CODE_LENGTH = 6;
const CODE_MAX_ATTEMPTS = 5;
const appointments = () => db.collection("appointments");
const appointmentCodes = () => db.collection("appointmentCodes");
const NAME_MAX_LENGTH = 30;
// Firestore gRPC 상태 코드 NOT_FOUND
const FIRESTORE_NOT_FOUND = 5;
const PLACE_TYPES = ["SUBWAY", "RESTAURANT", "CAFE", "HOSPITAL", "STATION", "SHOP", "OTHER"];

// MARK: - 생성

/**
 * 고유 코드를 만들어 약속 문서를 생성하고, 만든 사람을 첫 참여자로 넣는다.
 * 요청: { name, dateTime(epoch ms), place? } / 응답: 약속 응답 형식
 */
exports.createAppointment = onCall(async (request) => {
  const userID = requireUserID(request);
  const {name, dateTime, place} = request.data ?? {};

  const appointmentData = {
    name: parseName(name),
    dateTime: parseDateTime(dateTime),
    participantIDs: [userID],
  };
  if (place != null) {
    appointmentData.place = parsePlace(place);
  }

  const {appointmentID, code} = await createWithUniqueCode(appointmentData);
  return makeAppointmentResponse(appointmentID, {...appointmentData, code});
});

// MARK: - 참여

/**
 * 코드로 약속을 찾아 참여자에 추가한다. 이미 참여 중이면 그대로 돌려준다.
 * 요청: { code } / 응답: 약속 응답 형식. 코드에 맞는 약속이 없으면 not-found
 */
exports.joinAppointment = onCall(async (request) => {
  const userID = requireUserID(request);
  const code = parseCode(request.data?.code);

  const codeSnapshot = await appointmentCodes().doc(code).get();
  if (!codeSnapshot.exists) {
    throw new HttpsError("not-found", "코드에 해당하는 약속이 없습니다.");
  }

  const appointmentRef = appointments().doc(codeSnapshot.get("appointmentID"));
  try {
    await appointmentRef.update({participantIDs: FieldValue.arrayUnion(userID)});
  } catch (error) {
    // 코드를 찾은 직후 마지막 참여자가 나가 약속이 지워진 경우
    if (error.code === FIRESTORE_NOT_FOUND) {
      throw new HttpsError("not-found", "코드에 해당하는 약속이 없습니다.");
    }
    throw error;
  }

  const joined = await appointmentRef.get();
  return makeAppointmentResponse(joined.id, joined.data());
});

// MARK: - 나가기

/**
 * 참여자 목록에서 나를 뺀다. 마지막 참여자였으면 약속 문서·하위 컬렉션·코드 예약을 모두 지운다.
 * 이미 없는 약속이거나 참여하지 않은 약속이면 아무것도 하지 않고 성공한다.
 * 요청: { appointmentID } / 응답: 없음
 */
exports.leaveAppointment = onCall(async (request) => {
  const userID = requireUserID(request);
  const appointmentID = request.data?.appointmentID;
  if (typeof appointmentID !== "string" || appointmentID.length === 0) {
    throw new HttpsError("invalid-argument", "appointmentID가 필요합니다.");
  }

  const appointmentRef = appointments().doc(appointmentID);
  // 두 사람이 동시에 나가도 마지막 한 명을 정확히 판단하도록 트랜잭션으로 처리한다
  const isEmptied = await db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(appointmentRef);
    if (!snapshot.exists) return false;

    const participantIDs = snapshot.get("participantIDs") ?? [];
    if (!participantIDs.includes(userID)) return false;

    const remainingIDs = participantIDs.filter((id) => id !== userID);
    if (remainingIDs.length > 0) {
      transaction.update(appointmentRef, {participantIDs: remainingIDs});
      return false;
    }
    transaction.delete(appointmentRef);
    // 코드 예약도 같이 풀어 다른 약속이 같은 코드를 다시 쓸 수 있게 한다
    transaction.delete(appointmentCodes().doc(snapshot.get("code")));
    return true;
  });

  // 하위 컬렉션(routes, chats, sharedPlaces)은 트랜잭션 밖에서 지운다
  if (isEmptied) {
    await db.recursiveDelete(appointmentRef);
  }
  return {};
});

// MARK: - 요청 검증

function requireUserID(request) {
  const userID = request.auth?.uid;
  if (!userID) {
    throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
  }
  return userID;
}

function parseName(name) {
  const trimmed = typeof name === "string" ? name.trim() : "";
  if (trimmed.length === 0 || trimmed.length > NAME_MAX_LENGTH) {
    throw new HttpsError("invalid-argument", `약속 이름은 1~${NAME_MAX_LENGTH}자여야 합니다.`);
  }
  return trimmed;
}

function parseDateTime(dateTime) {
  if (!Number.isFinite(dateTime)) {
    throw new HttpsError("invalid-argument", "dateTime은 epoch 밀리초여야 합니다.");
  }
  return Timestamp.fromMillis(dateTime);
}

function parseCode(code) {
  const normalized = typeof code === "string" ? code.trim().toUpperCase() : "";
  if (normalized.length !== CODE_LENGTH) {
    throw new HttpsError("not-found", "코드에 해당하는 약속이 없습니다.");
  }
  return normalized;
}

/** 앱이 보낸 장소를 저장 형식으로 옮긴다 — 알려진 필드만 남긴다 */
function parsePlace(place) {
  const {id, name, address, coordinate, type} = place;
  const isValid = typeof id === "string" &&
    typeof name === "string" &&
    typeof address === "string" &&
    Number.isFinite(coordinate?.latitude) &&
    Number.isFinite(coordinate?.longitude) &&
    PLACE_TYPES.includes(type);
  if (!isValid) {
    throw new HttpsError("invalid-argument", "장소 형식이 올바르지 않습니다.");
  }
  return {
    id,
    name,
    address,
    coordinate: {latitude: coordinate.latitude, longitude: coordinate.longitude},
    type,
  };
}

// MARK: - 코드 생성

/**
 * 코드 예약 문서와 약속 문서를 한 트랜잭션으로 만든다.
 * 트랜잭션 안에서 읽은 예약 문서는 커밋까지 잠기므로, 두 요청이 같은 코드를 뽑아도 한쪽만 성공하고
 * 나머지는 이미 있는 예약을 보고 새 코드로 다시 시도한다
 */
async function createWithUniqueCode(appointmentData) {
  for (let attempt = 0; attempt < CODE_MAX_ATTEMPTS; attempt++) {
    const code = randomCode();
    const codeRef = appointmentCodes().doc(code);
    const appointmentRef = appointments().doc();

    const isCreated = await db.runTransaction(async (transaction) => {
      const reserved = await transaction.get(codeRef);
      if (reserved.exists) return false;

      transaction.create(codeRef, {appointmentID: appointmentRef.id});
      transaction.create(appointmentRef, {...appointmentData, code});
      return true;
    });
    if (isCreated) return {appointmentID: appointmentRef.id, code};
  }
  throw new HttpsError("resource-exhausted", "약속 코드를 만들지 못했습니다. 다시 시도해 주세요.");
}

function randomCode() {
  return Array.from({length: CODE_LENGTH}, () => CODE_ALPHABET[randomInt(CODE_ALPHABET.length)]).join("");
}

// MARK: - 응답

/**
 * 약속 응답 형식: { id, code, name, dateTime(epoch ms), place?, participants: [사용자] }
 * 참여자는 다른 사람에게 보여도 되는 프로필 필드만 담는다
 */
async function makeAppointmentResponse(appointmentID, data) {
  return {
    id: appointmentID,
    code: data.code,
    name: data.name,
    dateTime: data.dateTime.toMillis(),
    place: data.place ?? null,
    participants: await fetchParticipants(data.participantIDs ?? []),
  };
}

async function fetchParticipants(participantIDs) {
  if (participantIDs.length === 0) return [];

  const refs = participantIDs.map((id) => db.collection("users").doc(id));
  const snapshots = await db.getAll(...refs);
  return snapshots
      .filter((snapshot) => snapshot.exists)
      .map((snapshot) => ({
        id: snapshot.id,
        nickname: snapshot.get("nickname"),
        profileImage: snapshot.get("profileImage"),
        defaultTransportMode: snapshot.get("defaultTransportMode") ?? null,
        locationSharingScope: snapshot.get("locationSharingScope") ?? null,
      }));
}
