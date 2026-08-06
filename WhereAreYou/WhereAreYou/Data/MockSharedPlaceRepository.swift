//
//  MockSharedPlaceRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-03.
//

import Foundation

final class MockSharedPlaceRepository: SharedPlaceRepository {

    private static let currentUserID = "me"

    private var sharedPlaces: [String: [SharedPlace]] = [:]
    private var initialized: Set<String> = []

    private static let currentUser = User(
        id: currentUserID,
        nickname: "나",
        profileImage: URL(string: "https://placeholder")!,
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

    func fetchSharedPlaces(
        appointmentID: String,
        completion: @escaping (Result<[SharedPlace], Error>) -> Void
    ) {
        if !initialized.contains(appointmentID) {
            sharedPlaces[appointmentID] = Self.makeMockSharedPlaces(appointmentID: appointmentID)
            initialized.insert(appointmentID)
        }

        let result = sharedPlaces[appointmentID] ?? []
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            completion(.success(result))
        }
    }

    func sharePlace(
        appointmentID: String,
        place: Place,
        completion: @escaping (Result<SharedPlace, Error>) -> Void
    ) {
        if !initialized.contains(appointmentID) {
            sharedPlaces[appointmentID] = Self.makeMockSharedPlaces(appointmentID: appointmentID)
            initialized.insert(appointmentID)
        }

        if let existing = sharedPlaces[appointmentID]?.first(where: { $0.place.id == place.id }) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                completion(.success(existing))
            }
            return
        }

        let shared = SharedPlace(
            id: "sp_\(place.id)",
            appointmentID: appointmentID,
            place: place,
            sharedBy: Self.currentUser,
            sharedAt: Date(),
            voters: []
        )

        sharedPlaces[appointmentID, default: []].append(shared)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            completion(.success(shared))
        }
    }

    func voteForPlace(
        appointmentID: String,
        placeID: String,
        completion: @escaping (Result<SharedPlace, Error>) -> Void
    ) {
        guard var places = sharedPlaces[appointmentID],
              let index = places.firstIndex(where: { $0.id == placeID })
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                completion(.failure(NSError(domain: "SharedPlace", code: 404)))
            }
            return
        }

        var place = places[index]
        if place.voters.contains(where: { $0.id == Self.currentUserID }) {
            place.voters.removeAll { $0.id == Self.currentUserID }
        } else {
            place.voters.append(Self.currentUser)
        }
        places[index] = place
        sharedPlaces[appointmentID] = places

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            completion(.success(place))
        }
    }

    private static func makeMockSharedPlaces(appointmentID: String) -> [SharedPlace] {
        let now = Date()

        let gangnam = SharedPlace(
            id: "sp_gangnam",
            appointmentID: appointmentID,
            place: Place(
                id: "gangnam", name: "강남역",
                address: "서울 강남구 강남대로 396",
                coordinate: Coordinate(latitude: 37.4979, longitude: 127.0276),
                type: .subway
            ),
            sharedBy: user2,
            sharedAt: Calendar.current.date(byAdding: .minute, value: -54, to: now)!,
            voters: [user2, user3]
        )

        let hongdae = SharedPlace(
            id: "sp_hongdae",
            appointmentID: appointmentID,
            place: Place(
                id: "hongdae", name: "홍대입구역",
                address: "서울 마포구 양화로 160",
                coordinate: Coordinate(latitude: 37.5571, longitude: 126.9236),
                type: .subway
            ),
            sharedBy: user3,
            sharedAt: Calendar.current.date(byAdding: .minute, value: -52, to: now)!,
            voters: [user3]
        )

        return [gangnam, hongdae]
    }

}
