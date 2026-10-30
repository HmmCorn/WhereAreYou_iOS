//
//  KakaoCarRouteResponse.swift
//  WhereAreYou
//
//  Created by 김성훈 on 10/30/26.
//

import Foundation

/// 카카오모빌리티 자동차 길찾기 응답, 현재·미래 길찾기 공용
struct KakaoCarRouteResponse: Decodable {
    let routes: [KakaoCarRoute]
}

/// 자동차 경로
struct KakaoCarRoute: Decodable {
    /// 0이면 성공, 실패 시 summary·sections 없음
    let resultCode: Int
    let summary: KakaoCarRouteSummary?
    let sections: [KakaoCarSection]?

    enum CodingKeys: String, CodingKey {
        case resultCode = "result_code"
        case summary
        case sections
    }
}

/// 자동차 경로 전체 요약
struct KakaoCarRouteSummary: Decodable {
    /// 전체 거리(m)
    let distance: Double
    /// 전체 소요 시간(초)
    let duration: Double
}

/// 경유지 기준 구간
struct KakaoCarSection: Decodable {
    let roads: [KakaoCarRoad]
}

/// 도로 단위 구간
struct KakaoCarRoad: Decodable {
    /// 경도, 위도가 번갈아 나오는 좌표 목록
    let vertexes: [Double]
}

extension KakaoCarRoad {

    /// Coordinate 목록으로 변환, 짝이 맞지 않는 마지막 값은 제외
    var coordinates: [Coordinate] {
        stride(from: 0, to: vertexes.count - 1, by: 2).map { index in
            Coordinate(latitude: vertexes[index + 1], longitude: vertexes[index])
        }
    }
}

extension KakaoCarRouteResponse {

    /// Route 목록으로 변환, 탐색 실패한 경로는 제외
    func toRoutes(departure: Place, destination: Place, departureTime: Date) -> [Route] {
        routes.compactMap { route in
            guard route.resultCode == 0, let summary = route.summary else { return nil }

            let distanceKm = summary.distance / 1000
            let step = RouteStep(
                departurePoint: departure,
                destination: destination,
                estimatedTime: summary.duration / 60,
                distance: distanceKm,
                transportType: .car,
                path: (route.sections ?? []).flatMap(\.roads).flatMap(\.coordinates)
            )
            return Route(
                departureTime: departureTime,
                arrivalTime: departureTime.addingTimeInterval(summary.duration),
                step: [step],
                totalDistance: distanceKm
            )
        }
    }
}
