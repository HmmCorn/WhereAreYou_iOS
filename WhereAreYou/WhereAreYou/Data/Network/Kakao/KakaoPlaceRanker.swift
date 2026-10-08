//
//  KakaoPlaceRanker.swift
//  WhereAreYou
//
//  Created by 김성훈 on 10/8/26.
//

import Foundation

/// 키워드 검색 결과 재정렬
nonisolated enum KakaoPlaceRanker {

    /// 이름이 키워드와 일치하는 정도
    nonisolated private enum MatchLevel: Int, Comparable {
        case none
        case contains
        case prefix
        case exact

        static func < (lhs: MatchLevel, rhs: MatchLevel) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    nonisolated private struct Candidate {
        let document: KakaoPlaceDocument
        let originalIndex: Int
        let matchLevel: MatchLevel
        let representativeness: Double
        let distanceMeters: Double?
        let lengthRatio: Double
    }

    static func rank(_ documents: [KakaoPlaceDocument], keyword: String) -> [KakaoPlaceDocument] {
        let normalizedKeyword = normalize(keyword)
        guard !normalizedKeyword.isEmpty else { return documents }

        let usesDistance = documents.allSatisfy { $0.distanceMeters != nil }

        return documents.enumerated()
            .map {
                candidate(of: $1, at: $0, normalizedKeyword: normalizedKeyword, usesDistance: usesDistance)
            }
            .sorted(by: isOrderedBefore)
            .map(\.document)
    }

    // MARK: - Private

    private static func candidate(
        of document: KakaoPlaceDocument,
        at index: Int,
        normalizedKeyword: String,
        usesDistance: Bool
    ) -> Candidate {
        let normalizedName = normalize(document.placeName)
        let representativeness = KakaoCategoryGroupCode(rawValue: document.categoryGroupCode)?.representativeness
            ?? KakaoCategoryGroupCode.defaultRepresentativeness
        let lengthRatio = normalizedName.isEmpty
            ? 0
            : Double(normalizedKeyword.count) / Double(normalizedName.count)

        return Candidate(
            document: document,
            originalIndex: index,
            matchLevel: matchLevel(name: normalizedName, keyword: normalizedKeyword),
            representativeness: representativeness,
            distanceMeters: usesDistance ? document.distanceMeters : nil,
            lengthRatio: lengthRatio
        )
    }

    private static func matchLevel(name: String, keyword: String) -> MatchLevel {
        if name == keyword { return .exact }
        if name.hasPrefix(keyword) { return .prefix }
        if name.contains(keyword) { return .contains }
        return .none
    }

    /// 앞 기준이 같을 때만 다음 기준으로 비교, 마지막은 원래 순서로 안정 정렬 보장
    private static func isOrderedBefore(_ lhs: Candidate, _ rhs: Candidate) -> Bool {
        if lhs.matchLevel != rhs.matchLevel { return lhs.matchLevel > rhs.matchLevel }
        if lhs.representativeness != rhs.representativeness { return lhs.representativeness > rhs.representativeness }
        if let lhsDistance = lhs.distanceMeters, let rhsDistance = rhs.distanceMeters, lhsDistance != rhsDistance {
            return lhsDistance < rhsDistance
        }
        if lhs.lengthRatio != rhs.lengthRatio { return lhs.lengthRatio > rhs.lengthRatio }
        return lhs.originalIndex < rhs.originalIndex
    }

    /// 소문자 변환, 공백 제거
    private static func normalize(_ text: String) -> String {
        text.lowercased().filter { !$0.isWhitespace }
    }
}
