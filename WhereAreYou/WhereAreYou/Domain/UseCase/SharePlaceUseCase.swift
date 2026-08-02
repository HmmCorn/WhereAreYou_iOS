//
//  SharePlaceUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-03.
//

final class SharePlaceUseCase {

    private let repository: ChatRepository

    init(repository: ChatRepository) {
        self.repository = repository
    }

    func execute(
        appointmentID: String,
        place: Place,
        completion: @escaping (Result<Chat, Error>) -> Void
    ) {
        repository.sharePlace(appointmentID: appointmentID, place: place, completion: completion)
    }

}
