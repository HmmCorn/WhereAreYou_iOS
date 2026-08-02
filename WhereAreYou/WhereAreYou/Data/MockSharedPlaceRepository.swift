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

    func fetchSharedPlaces(
        appointmentID: String,
        completion: @escaping (Result<[SharedPlace], Error>) -> Void
    ) {
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
        let shared = SharedPlace(
            id: "sp_\(place.id)_\(Date().timeIntervalSince1970)",
            place: place,
            sharedBy: Self.currentUser,
            sharedAt: Date(),
            voters: []
        )

        if sharedPlaces[appointmentID] == nil {
            sharedPlaces[appointmentID] = []
        }
        sharedPlaces[appointmentID]?.append(shared)

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

}
