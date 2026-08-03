//
//  SharePlaceUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-03.
//

final class SharePlaceUseCase {

    private let chatRepository: ChatRepository
    private let sharedPlaceRepository: SharedPlaceRepository

    init(chatRepository: ChatRepository, sharedPlaceRepository: SharedPlaceRepository) {
        self.chatRepository = chatRepository
        self.sharedPlaceRepository = sharedPlaceRepository
    }

    func execute(
        appointmentID: String,
        place: Place,
        completion: @escaping (Result<Chat, Error>) -> Void
    ) {
        sharedPlaceRepository.sharePlace(appointmentID: appointmentID, place: place) { _ in }
        chatRepository.sharePlace(appointmentID: appointmentID, place: place, completion: completion)
    }

}
