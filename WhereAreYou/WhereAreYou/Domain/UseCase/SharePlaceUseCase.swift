//
//  SharePlaceUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-03.
//

/// 장소를 채팅으로 공유하고, 공유 장소 목록에 등록한다
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
        sharedPlaceRepository.sharePlace(appointmentID: appointmentID, place: place) { [chatRepository] result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success:
                chatRepository.sharePlace(appointmentID: appointmentID, place: place, completion: completion)
            }
        }
    }

}
