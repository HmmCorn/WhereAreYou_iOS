//
//  VotePlaceUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-03.
//

final class VotePlaceUseCase {

    private let repository: SharedPlaceRepository

    init(repository: SharedPlaceRepository) {
        self.repository = repository
    }

    func execute(
        appointmentID: String,
        placeID: String,
        completion: @escaping (Result<SharedPlace, Error>) -> Void
    ) {
        repository.voteForPlace(appointmentID: appointmentID, placeID: placeID, completion: completion)
    }

}
