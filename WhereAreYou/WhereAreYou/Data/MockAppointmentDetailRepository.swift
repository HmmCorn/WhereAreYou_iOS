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
            currentUserId: makeRoute(
                to: place, departureTime: now.addingTimeInterval(-45 * 60),
                arrivalTime: now.addingTimeInterval(13 * 60),
                start: Coordinate(latitude: 37.4930, longitude: 127.0180),
                transportType: .car
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

}
