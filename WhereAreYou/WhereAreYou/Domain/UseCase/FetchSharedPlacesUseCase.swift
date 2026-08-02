//
//  FetchSharedPlacesUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-03.
//

final class FetchSharedPlacesUseCase {

    private let repository: SharedPlaceRepository

    init(repository: SharedPlaceRepository) {
        self.repository = repository
    }

    func execute(
        appointmentID: String,
        completion: @escaping (Result<[SharedPlace], Error>) -> Void
    ) {
        repository.fetchSharedPlaces(appointmentID: appointmentID, completion: completion)
    }

}
