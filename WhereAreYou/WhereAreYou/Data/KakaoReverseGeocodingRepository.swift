//
//  KakaoReverseGeocodingRepository.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/29/26.
//

import Foundation

/// 카카오 로컬 API 기반 역지오코딩
final class KakaoReverseGeocodingRepository: ReverseGeocodingRepository {

    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func reverseGeocode(coordinate: Coordinate) async throws -> Place {
        do {
            let response: KakaoAddressResponse = try await apiClient.request(
                KakaoLocalEndpoint.coord2address(coordinate: coordinate)
            )
            return try response.toPlace(coordinate: coordinate)
        } catch let error as NetworkError {
            throw error.appError
        }
    }
}
