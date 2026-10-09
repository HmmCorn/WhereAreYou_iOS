//
//  ShareLocationUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-03.
//

/// 내 위치를 채팅으로 공유한다
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
        repository.sendChat(appointmentID: appointmentID, contentType: .locationShare(coordinate), completion: completion)
    }

}
