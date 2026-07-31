//
//  MockAppointmentDetailRepository.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/31/26.
//

import Foundation

final class MockAppointmentDetailRepository: AppointmentDetailRepository {

    func fetchAppointment(
        appointmentId: String,
        completion: @escaping (Result<(appointment: Appointment, currentUserId: String), Error>) -> Void
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let appointment = Self.makeMockAppointment(appointmentId: appointmentId)
            completion(.success((appointment: appointment, currentUserId: Self.currentUserId)))
        }
    }

    private static let currentUserId = "user_me"

    private static func profileImageURL(_ assetName: String) -> URL {
        URL(string: "asset://\(assetName)")!
    }

    private static func makeMockAppointment(appointmentId: String) -> Appointment {
        let place = Place(
            id: "place_starbucks_gangnam",
            name: "스타벅스 강남역점",
            address: "서울 강남구 강남대로 396",
            coordinate: Coordinate(latitude: 37.4979, longitude: 127.0276),
            type: .cafe
        )

        let now = Date()

        let users: [User] = [
            User(
                id: currentUserId,
                nickname: "나",
                profileImage: profileImageURL("shark"),
                defaultTransportMode: .car,
                locationSharingScope: .onlyDuringAppointment,
                isNotificationEnabled: true,
                appointmentsNotification: [:]
            ),
            User(
                id: "user_minji",
                nickname: "김민지",
                profileImage: profileImageURL("turtle"),
                defaultTransportMode: .transit,
                locationSharingScope: .onlyDuringAppointment,
                isNotificationEnabled: true,
                appointmentsNotification: [:]
            ),
            User(
                id: "user_seoyeon",
                nickname: "이서연",
                profileImage: profileImageURL("shark"),
                defaultTransportMode: .car,
                locationSharingScope: .onlyDuringAppointment,
                isNotificationEnabled: true,
                appointmentsNotification: [:]
            ),
            User(
                id: "user_junwoo",
                nickname: "박준우",
                profileImage: profileImageURL("turtle"),
                defaultTransportMode: .transit,
                locationSharingScope: .onlyDuringAppointment,
                isNotificationEnabled: true,
                appointmentsNotification: [:]
            ),
            User(
                id: "user_gildong",
                nickname: "최길동",
                profileImage: profileImageURL("shark"),
                defaultTransportMode: .walk,
                locationSharingScope: .onlyDuringAppointment,
                isNotificationEnabled: true,
                appointmentsNotification: [:]
            ),
            User(
                id: "user_subin",
                nickname: "정수빈",
                profileImage: profileImageURL("turtle"),
                defaultTransportMode: .car,
                locationSharingScope: .onlyDuringAppointment,
                isNotificationEnabled: true,
                appointmentsNotification: [:]
            ),
        ]

        let routes: [String: Route] = [
            currentUserId: makeMultiStepRoute(
                to: place, departureTime: now.addingTimeInterval(-45 * 60),
                arrivalTime: now.addingTimeInterval(13 * 60),
                start: Coordinate(latitude: 37.4930, longitude: 127.0180)
            ),
            "user_minji": makeRoute(
                to: place, departureTime: now.addingTimeInterval(-40 * 60),
                arrivalTime: now.addingTimeInterval(8 * 60),
                start: Coordinate(latitude: 37.5040, longitude: 127.0350),
                transportType: .transit
            ),
            "user_seoyeon": makeRoute(
                to: place, departureTime: now.addingTimeInterval(-38 * 60),
                arrivalTime: now.addingTimeInterval(7 * 60),
                start: Coordinate(latitude: 37.4990, longitude: 127.0120),
                transportType: .car
            ),
            "user_junwoo": makeRoute(
                to: place, departureTime: now.addingTimeInterval(-30 * 60),
                arrivalTime: now.addingTimeInterval(10 * 60),
                start: Coordinate(latitude: 37.4900, longitude: 127.0300),
                transportType: .transit
            ),
            "user_gildong": makeRoute(
                to: place, departureTime: now.addingTimeInterval(-25 * 60),
                arrivalTime: now.addingTimeInterval(15 * 60),
                start: Coordinate(latitude: 37.4965, longitude: 127.0230),
                transportType: .walk
            ),
            "user_subin": makeRoute(
                to: place, departureTime: now.addingTimeInterval(-20 * 60),
                arrivalTime: now.addingTimeInterval(11 * 60),
                start: Coordinate(latitude: 37.5010, longitude: 127.0400),
                transportType: .car
            ),
        ]

        return Appointment(
            id: appointmentId,
            code: "MOCK1234",
            name: "고기굽는방앗간 이수역점",
            dateTime: now.addingTimeInterval(13 * 60),
            place: place,
            participants: users,
            routes: routes,
            placeVoteStatus: [:]
        )
    }

    private static func makeRoute(
        to destination: Place,
        departureTime: Date,
        arrivalTime: Date,
        start: Coordinate,
        transportType: TransportType
    ) -> Route {
        let departurePlace = Place(
            id: "start_\(UUID().uuidString)",
            name: "출발지",
            address: "",
            coordinate: start,
            type: .other
        )

        let path = interpolatedPath(from: start, to: destination.coordinate, segments: 6)

        let step = RouteStep(
            departurePoint: departurePlace,
            destination: destination,
            estimatedTime: arrivalTime.timeIntervalSince(departureTime) / 60,
            distance: start.distance(to: destination.coordinate),
            transportType: transportType,
            path: path
        )

        return Route(
            departureTime: departureTime,
            arrivalTime: arrivalTime,
            step: [step],
            totalDistance: step.distance
        )
    }

    private static func interpolatedPath(
        from start: Coordinate, to end: Coordinate, segments: Int
    ) -> [Coordinate] {
        (0...segments).map { index in
            let ratio = Double(index) / Double(segments)
            let jitter = (index % 2 == 0 ? 1.0 : -1.0) * 0.0006 * (1 - ratio)
            return Coordinate(
                latitude: start.latitude + (end.latitude - start.latitude) * ratio + jitter,
                longitude: start.longitude + (end.longitude - start.longitude) * ratio
            )
        }
    }

    /// 나의 경로를 걷기 → 자동차 → 대중교통 → 걷기 4단계로 구성한 mock
    /// stepsStack 다중 스텝 렌더링 확인용
    private static func makeMultiStepRoute(
        to destination: Place,
        departureTime: Date,
        arrivalTime: Date,
        start: Coordinate
    ) -> Route {
        let totalMinutes = arrivalTime.timeIntervalSince(departureTime) / 60
        let ratios: [(TransportType, Double)] = [
            (.walk, 0.1),
            (.car, 0.35),
            (.transit, 0.4),
            (.walk, 0.15),
        ]

        let waypointRatios: [Double] = [0] + ratios.reduce(into: []) { result, item in
            result.append((result.last ?? 0) + item.1)
        }

        let waypoints = waypointRatios.map { ratio in
            Coordinate(
                latitude: start.latitude + (destination.coordinate.latitude - start.latitude) * ratio,
                longitude: start.longitude + (destination.coordinate.longitude - start.longitude) * ratio
            )
        }

        let places = waypoints.enumerated().map { index, coordinate in
            index == waypoints.count - 1
                ? destination
                : Place(id: "waypoint_\(index)_\(UUID().uuidString)", name: "경유지", address: "", coordinate: coordinate, type: .other)
        }

        let steps = ratios.enumerated().map { index, item -> RouteStep in
            let (transportType, ratio) = item
            let from = places[index]
            let to = places[index + 1]
            return RouteStep(
                departurePoint: from,
                destination: to,
                estimatedTime: totalMinutes * ratio,
                distance: from.coordinate.distance(to: to.coordinate),
                transportType: transportType,
                path: interpolatedPath(from: from.coordinate, to: to.coordinate, segments: 3)
            )
        }

        return Route(
            departureTime: departureTime,
            arrivalTime: arrivalTime,
            step: steps,
            totalDistance: steps.reduce(0) { $0 + $1.distance }
        )
    }

}
