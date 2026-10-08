//
//  KakaoPlaceSearchRepository.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/29/26.
//

import Foundation

/// 카카오 로컬 API 기반 키워드 장소 검색
final class KakaoPlaceSearchRepository: PlaceSearchRepository {

    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func searchPlaces(keyword: String, near coordinate: Coordinate?) async throws -> [Place] {
        async let firstPage = fetchDocuments(keyword: keyword, page: 1, coordinate: coordinate)
        async let secondPage = fetchDocumentsIgnoringFailure(keyword: keyword, page: 2, coordinate: coordinate)
        async let nearestPage = fetchNearestDocuments(keyword: keyword, coordinate: coordinate)

        let documents = try await firstPage + secondPage + nearestPage

        var seenIDs = Set<String>()
        let uniqueDocuments = documents.filter { seenIDs.insert($0.id).inserted }

        return KakaoPlaceRanker.rank(uniqueDocuments, keyword: keyword)
            .compactMap { $0.toPlace() }
    }

    // MARK: - Private

    private func fetchDocuments(
        keyword: String,
        page: Int,
        coordinate: Coordinate?,
        sort: KakaoKeywordSort = .accuracy
    ) async throws -> [KakaoPlaceDocument] {
        let response: KakaoPlaceResponse = try await apiClient.request(
            KakaoLocalEndpoint.keyword(query: keyword, page: page, coordinate: coordinate, sort: sort)
        )
        return response.documents
    }

    /// 보조 페이지 조회
    private func fetchDocumentsIgnoringFailure(
        keyword: String,
        page: Int,
        coordinate: Coordinate?,
        sort: KakaoKeywordSort = .accuracy
    ) async throws -> [KakaoPlaceDocument] {
        do {
            return try await fetchDocuments(keyword: keyword, page: page, coordinate: coordinate, sort: sort)
        } catch {
            try Task.checkCancellation()
            return []
        }
    }

    /// 기준 좌표에서 가까운 순 후보 조회
    private func fetchNearestDocuments(keyword: String, coordinate: Coordinate?) async throws -> [KakaoPlaceDocument] {
        guard let coordinate else { return [] }
        return try await fetchDocumentsIgnoringFailure(
            keyword: keyword,
            page: 1,
            coordinate: coordinate,
            sort: .distance
        )
    }
}
