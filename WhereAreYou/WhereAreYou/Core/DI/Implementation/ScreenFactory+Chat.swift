//
//  ScreenFactory+Chat.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

import Foundation

extension ScreenFactory {

    func makeChatViewController(appointmentInfo: AppointmentInfo) -> ChatViewController {
        let chatRepository = container.resolve(ChatRepository.self)
        let viewModel = ChatViewModel(
            appointmentInfo: appointmentInfo,
            fetchMessagesUseCase: FetchMessagesUseCase(repository: chatRepository),
            sendMessageUseCase: SendMessageUseCase(repository: chatRepository),
            getCurrentLocationUseCase: GetCurrentLocationUseCase(
                repository: container.resolve(LocationRepository.self)
            ),
            shareLocationUseCase: ShareLocationUseCase(repository: chatRepository),
            sharePlaceUseCase: SharePlaceUseCase(
                chatRepository: chatRepository,
                sharedPlaceRepository: container.resolve(SharedPlaceRepository.self)
            )
        )
        return ChatViewController(viewModel: viewModel)
    }

    /// 약속 ID로 약속 정보를 조회한 뒤, 성공 시 채팅 화면을 만들어 completion으로 전달
    /// (Home/AppointmentList/PastAppointmentList에서 공통으로 쓰는 "ID로 채팅 열기" 흐름)
    func makeChatViewController(
        appointmentID: String,
        completion: @escaping (Result<ChatViewController, Error>) -> Void
    ) {
        let repository = container.resolve(AppointmentInfoRepository.self)
        FetchAppointmentInfoUseCase(repository: repository).execute(appointmentID: appointmentID) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let appointment):
                let chatViewController = self.makeChatViewController(
                    appointmentInfo: AppointmentInfo(appointment: appointment)
                )
                completion(.success(chatViewController))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}
