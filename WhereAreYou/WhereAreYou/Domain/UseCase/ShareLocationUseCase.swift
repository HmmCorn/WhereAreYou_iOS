//
//  ShareLocationUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-03.
//

final class ShareLocationUseCase {

    private let repository: ChatRepository

    init(repository: ChatRepository) {
        self.repository = repository
    }

    func execute(
        appointmentID: String,
        coordinate: Coordinate,
        completion: @escaping (Result<Chat, Error>) -> Void
    ) {
        repository.shareLocation(appointmentID: appointmentID, coordinate: coordinate, completion: completion)
    }

}
