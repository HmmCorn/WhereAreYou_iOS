//
//  SearchRoutesUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-22.
//

import Foundation

final class SearchRoutesUseCase {

    /// 대중교통 정렬 시 환승 1회당 더하는 시간(초)
    private static let transferPenalty: TimeInterval = 5 * 60

    private let repository: RouteSearchRepository

    init(repository: RouteSearchRepository) {
        self.repository = repository
    }

    func execute(
        departure: Place,
        destination: Place,
        departureTime: Date,
        transportType: TransportType
    ) async throws -> [Route] {
        let routes = try await repository.searchRoutes(
            departure: departure,
            destination: destination,
            departureTime: departureTime,
            transportType: transportType
        )
        return sorted(routes, transportType: transportType)
    }

    // MARK: - Private

    /// 이동수단별 추천 순 정렬
    /// 걷기·자동차: 소요시간 -> 거리, 대중교통: 소요시간 + 환승 페널티 -> 도보 시간
    private func sorted(_ routes: [Route], transportType: TransportType) -> [Route] {
        switch transportType {
        case .walk, .car:
            return routes.sorted {
                (duration(of: $0), $0.totalDistance) < (duration(of: $1), $1.totalDistance)
            }
        case .transit:
            return routes.sorted {
                (transitScore(of: $0), walkMinutes(of: $0)) < (transitScore(of: $1), walkMinutes(of: $1))
            }
        }
    }

    /// 전체 소요시간(초)
    private func duration(of route: Route) -> TimeInterval {
        route.arrivalTime.timeIntervalSince(route.departureTime)
    }

    /// 소요시간에 환승 횟수만큼 페널티를 더한 값
    private func transitScore(of route: Route) -> TimeInterval {
        let transitStepCount = route.step.filter { $0.transportType == .transit }.count
        let transferCount = max(transitStepCount - 1, 0)
        return duration(of: route) + Double(transferCount) * Self.transferPenalty
    }

    /// 도보 구간 시간 합(분)
    private func walkMinutes(of route: Route) -> Double {
        route.step
            .filter { $0.transportType == .walk }
            .reduce(0) { $0 + $1.estimatedTime }
    }

}
