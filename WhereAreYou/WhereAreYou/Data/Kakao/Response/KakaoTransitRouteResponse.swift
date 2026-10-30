//
//  KakaoTransitRouteResponse.swift
//  WhereAreYou
//
//  Created by 김성훈 on 10/30/26.
//

import Foundation

/// 카카오 대중교통 경로 조회 응답
struct KakaoTransitRouteResponse: Decodable {
    /// 탐색 결과 상태, OK가 아니면 routes 없음
    let status: String
    let routes: [KakaoTransitRoute]?
}

/// 대중교통 추천 경로
struct KakaoTransitRoute: Decodable {
    let properties: KakaoTransitRouteProperties
    let steps: [KakaoTransitStep]
}

/// 대중교통 경로 전체 요약, 출발·도착 도보 포함
struct KakaoTransitRouteProperties: Decodable {
    /// 전체 거리(m)
    let totalDistance: Double
    /// 전체 소요 시간(초)
    let totalTime: Double
}

/// 이동수단 단위 구간, 출발·도착 도보는 빠짐
struct KakaoTransitStep: Decodable {
    let properties: KakaoTransitStepProperties
    let path: KakaoRoutePath
}

/// 구간 정보
struct KakaoTransitStepProperties: Decodable {
    /// BUS, SUBWAY, WALKING
    let type: String
    /// 구간 거리(m)
    let distance: Double
    /// 구간 소요 시간(초)
    let time: Double
    /// 탑승 ~ 하차 정류장 목록
    let stops: [KakaoTransitStop]?
    /// 이 구간을 갈 수 있는 노선 목록, 도보 구간은 없음
    let vehicles: [KakaoTransitVehicle]?
}

/// 정류장·역
struct KakaoTransitStop: Decodable {
    let name: String
}

/// 노선
struct KakaoTransitVehicle: Decodable {
    /// 노선명 (예: "146", "2호선")
    let name: String
    /// 노선 종류 (예: "간선", "마을", "일반")
    let type: String
}

extension KakaoTransitRouteResponse {

    /// Route 목록으로 변환, 탐색 실패 시 빈 배열
    func toRoutes(departure: Place, destination: Place, departureTime: Date) -> [Route] {
        guard status == "OK", let routes else { return [] }

        return routes.map { route in
            Route(
                departureTime: departureTime,
                arrivalTime: departureTime.addingTimeInterval(route.properties.totalTime),
                step: route.steps.map { $0.toRouteStep(departure: departure, destination: destination) },
                totalDistance: route.properties.totalDistance / 1000
            )
        }
    }
}

extension KakaoTransitStep {

    /// RouteStep으로 변환, 정류장·좌표가 없으면 전체 출발지·목적지로 대체
    func toRouteStep(departure: Place, destination: Place) -> RouteStep {
        let coordinates = path.coordinates
        let isWalking = properties.type == "WALKING"
        let vehicles = properties.vehicles ?? []
        let stops = properties.stops ?? []

        return RouteStep(
            departurePoint: makePlace(
                name: stops.first?.name ?? departure.name,
                coordinate: coordinates.first ?? departure.coordinate
            ),
            destination: makePlace(
                name: stops.last?.name ?? destination.name,
                coordinate: coordinates.last ?? destination.coordinate
            ),
            estimatedTime: properties.time / 60,
            distance: properties.distance / 1000,
            transportType: isWalking ? .walk : .transit,
            path: coordinates,
            lineName: isWalking ? nil : lineName(of: vehicles),
            lineColorHex: isWalking ? nil : lineColorHex(of: vehicles),
            stopCount: isWalking || stops.isEmpty ? nil : stops.count - 1
        )
    }

    // MARK: - Private

    /// 정류장·역 Place, 이름과 좌표로 식별
    private func makePlace(name: String, coordinate: Coordinate) -> Place {
        let placeType: PlaceType
        switch properties.type {
        case "SUBWAY": placeType = .subway
        case "BUS": placeType = .station
        default: placeType = .other
        }
        return Place(
            id: "\(name)_\(coordinate.latitude),\(coordinate.longitude)",
            name: name,
            address: "",
            coordinate: coordinate,
            type: placeType
        )
    }

    /// 중복 제거한 노선명 연결 (예: "146, 341, 360")
    private func lineName(of vehicles: [KakaoTransitVehicle]) -> String? {
        var seenNames = Set<String>()
        let names = vehicles.map(\.name).filter { seenNames.insert($0).inserted }
        return names.isEmpty ? nil : names.joined(separator: ", ")
    }

    /// 첫 번째 노선 기준 색
    private func lineColorHex(of vehicles: [KakaoTransitVehicle]) -> String? {
        guard let vehicle = vehicles.first else { return nil }
        if properties.type == "SUBWAY" {
            return KakaoTransitLineColor.subwayColorHex(lineName: vehicle.name)
        }
        return KakaoTransitLineColor.busColorHex(busType: vehicle.type, busName: vehicle.name)
    }
}
