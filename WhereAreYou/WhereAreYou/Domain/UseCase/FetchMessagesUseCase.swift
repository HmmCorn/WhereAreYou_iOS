//
//  FetchMessagesUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-30.
//

final class FetchMessagesUseCase {

    private let repository: ChatRepository

    init(repository: ChatRepository) {
        self.repository = repository
    }

    func execute(
        appointmentID: String,
        completion: @escaping (Result<[Chat], Error>) -> Void
    ) {
        repository.fetchMessages(appointmentID: appointmentID, completion: completion)
    }

}
