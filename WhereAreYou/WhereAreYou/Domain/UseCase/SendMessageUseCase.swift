//
//  SendMessageUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-30.
//

import Foundation

/// 텍스트 메시지를 전송한다
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
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        repository.sendChat(appointmentID: appointmentID, contentType: .text(content), completion: completion)
    }

}
