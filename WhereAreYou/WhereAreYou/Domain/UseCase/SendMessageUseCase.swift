//
//  SendMessageUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-30.
//

final class SendMessageUseCase {

    private let repository: ChatRepository

    init(repository: ChatRepository) {
        self.repository = repository
    }

    func execute(
        appointmentID: String,
        content: String,
        completion: @escaping (Result<Chat, Error>) -> Void
    ) {
        repository.sendMessage(appointmentID: appointmentID, content: content, completion: completion)
    }

}
