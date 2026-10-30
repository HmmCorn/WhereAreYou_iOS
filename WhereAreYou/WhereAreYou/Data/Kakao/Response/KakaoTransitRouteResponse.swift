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

        return routes.map { $0.toRoute(departure: departure, destination: destination, departureTime: departureTime) }
    }
}

extension KakaoTransitRoute {

    /// 추정 도보 구간 최소 시간(초), 이보다 짧으면 구간을 만들지 않음
    private static let minimumWalkTime: Double = 60

    /// Route로 변환, 응답에 없는 출발·도착 도보 구간은 추정해서 추가
    func toRoute(departure: Place, destination: Place, departureTime: Date) -> Route {
        var routeSteps = steps.map { $0.toRouteStep(departure: departure, destination: destination) }

        if let firstStep = routeSteps.first, let lastStep = routeSteps.last {
            let (startWalk, endWalk) = estimatedWalks(
                departure: departure,
                firstStop: firstStep.departurePoint,
                lastStop: lastStep.destination,
                destination: destination
            )
            if let startWalk { routeSteps.insert(startWalk, at: 0) }
            if let endWalk { routeSteps.append(endWalk) }
        }

        return Route(
            departureTime: departureTime,
            arrivalTime: departureTime.addingTimeInterval(properties.totalTime),
            step: routeSteps,
            totalDistance: properties.totalDistance / 1000
        )
    }

    // MARK: - Private

    /// 전체 값과 구간 합의 차이를 출발·도착 쪽 직선거리 비율로 나눈 도보 구간
    private func estimatedWalks(
        departure: Place,
        firstStop: Place,
        lastStop: Place,
        destination: Place
    ) -> (start: RouteStep?, end: RouteStep?) {
        let missingTime = properties.totalTime - steps.reduce(0) { $0 + $1.properties.time }
        let missingDistance = max(properties.totalDistance - steps.reduce(0) { $0 + $1.properties.distance }, 0)

        let startStraightDistance = departure.coordinate.distance(to: firstStop.coordinate)
        let endStraightDistance = lastStop.coordinate.distance(to: destination.coordinate)
        let totalStraightDistance = startStraightDistance + endStraightDistance
        guard missingTime > 0, totalStraightDistance > 0 else { return (nil, nil) }

        let startRatio = startStraightDistance / totalStraightDistance
        let start = makeWalkStep(
            from: departure,
            to: firstStop,
            time: missingTime * startRatio,
            distance: missingDistance * startRatio
        )
        let end = makeWalkStep(
            from: lastStop,
            to: destination,
            time: missingTime * (1 - startRatio),
            distance: missingDistance * (1 - startRatio)
        )
        return (start, end)
    }

    /// 두 지점을 직선으로 잇는 도보 구간, 최소 시간 미만이면 nil
    private func makeWalkStep(from: Place, to: Place, time: Double, distance: Double) -> RouteStep? {
        guard time >= Self.minimumWalkTime else { return nil }
        return RouteStep(
            departurePoint: from,
            destination: to,
            estimatedTime: time / 60,
            distance: distance / 1000,
            transportType: .walk,
            path: [from.coordinate, to.coordinate]
        )
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
