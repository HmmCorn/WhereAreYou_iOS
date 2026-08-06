//
//  MockAppointmentInfoRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-06.
//

import Foundation

final class MockAppointmentInfoRepository: AppointmentInfoRepository {

    func fetchAppointmentInfo(
        appointmentID: String,
        completion: @escaping (Result<Appointment, Error>) -> Void
    ) {
        let appointment = Self.makeMockAppointment(appointmentID: appointmentID)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            completion(.success(appointment))
        }
    }

    private static let currentUser = User(
        id: "me",
        nickname: "나",
        profileImage: URL(string: "otter")!,
        defaultTransportMode: .transit,
        locationSharingScope: .onlyDuringAppointment,
        isNotificationEnabled: true,
        appointmentsNotification: [:]
    )

    private static let user2 = User(
        id: "user2",
        nickname: "김길동",
        profileImage: URL(string: "shark")!,
        defaultTransportMode: .transit,
        locationSharingScope: .onlyDuringAppointment,
        isNotificationEnabled: true,
        appointmentsNotification: [:]
    )

    private static let user3 = User(
        id: "user3",
        nickname: "홍길동",
        profileImage: URL(string: "turtle")!,
        defaultTransportMode: .transit,
        locationSharingScope: .onlyDuringAppointment,
        isNotificationEnabled: true,
        appointmentsNotification: [:]
    )

    private static func makeMockAppointment(appointmentID: String) -> Appointment {
        let place = Place(
            id: "gangnam",
            name: "강남역",
            address: "서울 강남구 강남대로 396",
            coordinate: Coordinate(latitude: 37.4979, longitude: 127.0276),
            type: .subway
        )

        return Appointment(
            id: appointmentID,
            code: "ABCD1234",
            name: "강남역 모임",
            dateTime: Date().addingTimeInterval(3600),
            place: place,
            participants: [currentUser, user2, user3],
            routes: [:],
            placeVoteStatus: [:]
        )
    }

}
