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

    init(
        departurePoint: Place,
        destination: Place,
        estimatedTime: Double,
        distance: Double,
        transportType: TransportType,
        path: [Coordinate] = []
    ) {
        self.departurePoint = departurePoint
        self.destination = destination
        self.estimatedTime = estimatedTime
        self.distance = distance
        self.transportType = transportType
        self.path = path
    }

}
