//
//  RouteStep.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-14.
//

struct RouteStep {

    let departurePoint: Place
    let destination: Place
    let estimatedTime: Double
    let distance: Double
    let transportType: TransportType
    let path: [Coordinate]
    /// 대중교통 노선명 (예: "2호선", "146") — 도보·자동차는 nil
    let lineName: String?
    /// 노선 대표 색 hex (예: "#00A84D") — 도보·자동차는 nil
    let lineColorHex: String?
    /// 탑승역부터 하차역까지 정거장 수 — 도보·자동차는 nil
    let stopCount: Int?

    init(
        departurePoint: Place,
        destination: Place,
        estimatedTime: Double,
        distance: Double,
        transportType: TransportType,
        path: [Coordinate] = [],
        lineName: String? = nil,
        lineColorHex: String? = nil,
        stopCount: Int? = nil
    ) {
        self.departurePoint = departurePoint
        self.destination = destination
        self.estimatedTime = estimatedTime
        self.distance = distance
        self.transportType = transportType
        self.path = path
        self.lineName = lineName
        self.lineColorHex = lineColorHex
        self.stopCount = stopCount
    }

}
