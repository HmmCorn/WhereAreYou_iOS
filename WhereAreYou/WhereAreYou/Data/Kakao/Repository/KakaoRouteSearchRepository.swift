//
//  KakaoRouteSearchRepository.swift
//  WhereAreYou
//
//  Created by 김성훈 on 10/30/26.
//

import Foundation

/// 카카오 길찾기 API 기반 경로 검색
final class KakaoRouteSearchRepository: RouteSearchRepository {

    /// 자동차 미래 길찾기를 쓰는 기준, 출발 시각이 이보다 뒤면 교통 예측 적용
    private static let futureCarThreshold: TimeInterval = 10 * 60

    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func searchRoutes(
        departure: Place,
        destination: Place,
        departureTime: Date,
        transportType: TransportType
    ) async throws -> [Route] {
        switch transportType {
        case .walk:
            let response: KakaoWalkRouteResponse = try await apiClient.request(
                KakaoRouteEndpoint.walk(start: departure.coordinate, end: destination.coordinate)
            )
            return response.toRoutes(departure: departure, destination: destination, departureTime: departureTime)

        case .transit:
            // 출발 시각 파라미터가 없어 현재 기준 소요시간을 출발 시각에 더함
            let response: KakaoTransitRouteResponse = try await apiClient.request(
                KakaoRouteEndpoint.transit(start: departure.coordinate, end: destination.coordinate)
            )
            return response.toRoutes(departure: departure, destination: destination, departureTime: departureTime)

        case .car:
            let response: KakaoCarRouteResponse = try await apiClient.request(
                carEndpoint(departure: departure, destination: destination, departureTime: departureTime)
            )
            return response.toRoutes(departure: departure, destination: destination, departureTime: departureTime)
        }
    }

    // MARK: - Private

    /// 출발 시각에 따라 현재·미래 길찾기 선택
    private func carEndpoint(departure: Place, destination: Place, departureTime: Date) -> KakaoRouteEndpoint {
        guard departureTime.timeIntervalSinceNow > Self.futureCarThreshold else {
            return .car(origin: departure.coordinate, destination: destination.coordinate)
        }
        return .futureCar(
            origin: departure.coordinate,
            destination: destination.coordinate,
            departureTime: departureTime
        )
    }
}
