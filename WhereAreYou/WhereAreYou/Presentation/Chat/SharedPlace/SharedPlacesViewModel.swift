//
//  SharedPlacesViewModel.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-03.
//

import Foundation
import Combine

final class SharedPlacesViewModel {

    enum SortOrder {
        case newest
        case oldest
    }

    @Published private(set) var items: [SharedPlaceItem] = []
    @Published private(set) var sortOrder: SortOrder = .newest

    private let appointmentID: String
    private let currentUserID: String
    private var sharedPlaces: [SharedPlace] = []

    private let fetchSharedPlacesUseCase: FetchSharedPlacesUseCase
    private let votePlaceUseCase: VotePlaceUseCase

    init(
        appointmentID: String,
        currentUserID: String,
        fetchSharedPlacesUseCase: FetchSharedPlacesUseCase,
        votePlaceUseCase: VotePlaceUseCase
    ) {
        self.appointmentID = appointmentID
        self.currentUserID = currentUserID
        self.fetchSharedPlacesUseCase = fetchSharedPlacesUseCase
        self.votePlaceUseCase = votePlaceUseCase
    }

    func fetchPlaces() {
        fetchSharedPlacesUseCase.execute(appointmentID: appointmentID) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                if case .success(let places) = result {
                    self.sharedPlaces = places
                    self.buildItems()
                }
            }
        }
    }

    func voteForPlace(id placeID: String) {
        votePlaceUseCase.execute(appointmentID: appointmentID, placeID: placeID) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                if case .success(let updated) = result {
                    if let index = self.sharedPlaces.firstIndex(where: { $0.id == placeID }) {
                        self.sharedPlaces[index] = updated
                    }
                    self.buildItems()
                }
            }
        }
    }

    func updateSortOrder(_ order: SortOrder) {
        sortOrder = order
        buildItems()
    }

    private func buildItems() {
        var result = sharedPlaces.map { shared in
            SharedPlaceItem(
                id: shared.id,
                placeName: shared.place.name,
                placeAddress: shared.place.address,
                voterProfileImages: shared.voters.map { $0.profileImage.lastPathComponent },
                hasVoted: shared.voters.contains { $0.id == currentUserID },
                sharedAt: shared.sharedAt
            )
        }

        switch sortOrder {
        case .newest: result.sort { $0.sharedAt > $1.sharedAt }
        case .oldest: result.sort { $0.sharedAt < $1.sharedAt }
        }

        items = result
    }

}
