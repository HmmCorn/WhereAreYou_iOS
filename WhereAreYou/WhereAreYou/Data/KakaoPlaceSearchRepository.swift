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

    func searchPlaces(keyword: String) async throws -> [Place] {
        async let firstPage = fetchDocuments(keyword: keyword, page: 1)
        async let secondPage = fetchDocumentsIgnoringFailure(keyword: keyword, page: 2)

        let documents = try await firstPage + secondPage

        var seenIDs = Set<String>()
        return documents
            .filter { seenIDs.insert($0.id).inserted }
            .compactMap { $0.toPlace() }
    }

    // MARK: - Private

    private func fetchDocuments(keyword: String, page: Int) async throws -> [KakaoPlaceDocument] {
        let response: KakaoPlaceResponse = try await apiClient.request(
            KakaoLocalEndpoint.keyword(query: keyword, page: page)
        )
        return response.documents
    }

    /// 보조 페이지 조회
    private func fetchDocumentsIgnoringFailure(keyword: String, page: Int) async throws -> [KakaoPlaceDocument] {
        do {
            return try await fetchDocuments(keyword: keyword, page: page)
        } catch {
            try Task.checkCancellation()
            return []
        }
    }
}
