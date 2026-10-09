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
        let response: KakaoPlaceResponse = try await apiClient.request(
            KakaoLocalEndpoint.keyword(query: keyword)
        )
        return response.documents.compactMap { $0.toPlace() }
    }
}
