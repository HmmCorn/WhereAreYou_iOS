//
//  KakaoWalkRouteResponse.swift
//  WhereAreYou
//
//  Created by 김성훈 on 10/30/26.
//

import Foundation

/// 카카오 도보 경로 조회 응답
struct KakaoWalkRouteResponse: Decodable {
    /// 탐색 결과 상태, OK가 아니면 route 없음
    let status: String
    let route: KakaoWalkRoute?
}

/// 도보 경로
struct KakaoWalkRoute: Decodable {
    let properties: KakaoWalkRouteProperties
    let legs: [KakaoWalkLeg]
}

/// 도보 경로 전체 요약
struct KakaoWalkRouteProperties: Decodable {
    /// 전체 거리(m)
    let totalDistance: Double
    /// 전체 소요 시간(초)
    let totalTime: Double
}

/// 경유지 기준 도보 구간
struct KakaoWalkLeg: Decodable {
    let steps: [KakaoWalkStep]
}

/// 회전 지점 단위 도보 안내
struct KakaoWalkStep: Decodable {
    let path: KakaoRoutePath
}

/// 경로 좌표 목록
struct KakaoRoutePath: Decodable {
    /// [경도, 위도] 쌍 목록
    let points: [[Double]]
}

extension KakaoRoutePath {

    /// Coordinate 목록으로 변환, 쌍이 아닌 값은 제외
    var coordinates: [Coordinate] {
        points.compactMap { point in
            guard point.count >= 2 else { return nil }
            return Coordinate(latitude: point[1], longitude: point[0])
        }
    }
}

extension KakaoWalkRouteResponse {

    /// Route로 변환, 탐색 실패 시 빈 배열
    func toRoutes(departure: Place, destination: Place, departureTime: Date) -> [Route] {
        guard status == "OK", let route else { return [] }

        let distanceKm = route.properties.totalDistance / 1000
        let step = RouteStep(
            departurePoint: departure,
            destination: destination,
            estimatedTime: route.properties.totalTime / 60,
            distance: distanceKm,
            transportType: .walk,
            path: route.legs.flatMap(\.steps).flatMap(\.path.coordinates)
        )
        return [
            Route(
                departureTime: departureTime,
                arrivalTime: departureTime.addingTimeInterval(route.properties.totalTime),
                step: [step],
                totalDistance: distanceKm
            )
        ]
    }
}
