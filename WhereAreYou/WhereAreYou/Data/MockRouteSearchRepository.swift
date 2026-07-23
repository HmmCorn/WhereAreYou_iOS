//
//  MockRouteSearchRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-22.
//

import Foundation

final class MockRouteSearchRepository: RouteSearchRepository {

    func searchRoutes(
        departure: Place,
        destination: Place,
        departureTime: Date,
        transportType: TransportType,
        completion: @escaping (Result<[Route], Error>) -> Void
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let routes = Self.makeMockRoutes(
                departure: departure,
                destination: destination,
                departureTime: departureTime,
                transportType: transportType
            )
            completion(.success(routes))
        }
    }

    private static func makeMockRoutes(
        departure: Place,
        destination: Place,
        departureTime: Date,
        transportType: TransportType
    ) -> [Route] {
        let parking = Place(
            id: "parking", name: "주차장", address: "",
            coordinate: Coordinate(latitude: 0, longitude: 0), type: .other
        )
        let busStop = Place(
            id: "bus_stop", name: "정류장", address: "",
            coordinate: Coordinate(latitude: 0, longitude: 0), type: .station
        )

        switch transportType {
        case .car:
            return [
                Route(
                    departureTime: departureTime,
                    arrivalTime: departureTime.addingTimeInterval(285 * 60),
                    step: [
                        RouteStep(departurePoint: departure, destination: parking, estimatedTime: 10, distance: 0.5, transportType: .walk),
                        RouteStep(departurePoint: destination, destination: parking, estimatedTime: 260, distance: 280, transportType: .car),
                        RouteStep(departurePoint: parking, destination: destination, estimatedTime: 10, distance: 0.5, transportType: .walk)
                    ],
                    totalDistance: 281
                ),
                Route(
                    departureTime: departureTime,
                    arrivalTime: departureTime.addingTimeInterval(285 * 60),
                    step: [
                        RouteStep(departurePoint: departure, destination: parking, estimatedTime: 10, distance: 0.5, transportType: .walk),
                        RouteStep(departurePoint: destination, destination: parking, estimatedTime: 260, distance: 300, transportType: .car),
                        RouteStep(departurePoint: parking, destination: destination, estimatedTime: 10, distance: 0.8, transportType: .walk)
                    ],
                    totalDistance: 301.3
                )
            ]

        case .transit:
            return [
                Route(
                    departureTime: departureTime,
                    arrivalTime: departureTime.addingTimeInterval(195 * 60),
                    step: [
                        RouteStep(departurePoint: departure, destination: busStop, estimatedTime: 5, distance: 0.3, transportType: .walk),
                        RouteStep(departurePoint: busStop, destination: destination, estimatedTime: 180, distance: 200, transportType: .transit),
                        RouteStep(departurePoint: busStop, destination: destination, estimatedTime: 10, distance: 0.5, transportType: .walk)
                    ],
                    totalDistance: 200.8
                )
            ]

        case .walk:
            return [
                Route(
                    departureTime: departureTime,
                    arrivalTime: departureTime.addingTimeInterval(600 * 60),
                    step: [
                        RouteStep(departurePoint: departure, destination: destination, estimatedTime: 600, distance: 40, transportType: .walk)
                    ],
                    totalDistance: 40
                )
            ]
        }
    }

}
