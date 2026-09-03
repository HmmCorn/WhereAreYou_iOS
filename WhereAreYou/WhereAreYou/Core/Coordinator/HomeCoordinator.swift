//
//  HomeCoordinator.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

import UIKit

final class HomeCoordinator: NavigationCoordinator {

    let navigationController: UINavigationController
    private let screenFactory: ScreenFactory

    init(
        navigationController: UINavigationController,
        screenFactory: ScreenFactory = ScreenFactory()
    ) {
        self.navigationController = navigationController
        self.screenFactory = screenFactory
    }

    func start() {
        let viewController = HomeViewController()
        viewController.coordinator = self
        navigationController.setViewControllers([viewController], animated: false)
    }

    // MARK: - Appointment Creation

    func showAppointmentCreation() {
        push(screenFactory.makeAppointmentCreationViewController())
    }

    // MARK: - Join

    func joinAppointment(code: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let useCase = JoinAppointmentUseCase(
            repository: screenFactory.container.resolve(AppointmentDetailRepository.self)
        )
        useCase.execute(code: code) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let (appointment, _)):
                self.showChat(appointmentInfo: AppointmentInfo(appointment: appointment))
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Chat

    func showChat(appointmentID: String) {
        screenFactory.makeChatViewController(appointmentID: appointmentID) { [weak self] result in
            guard let self, case .success(let chatViewController) = result else { return }
            self.push(chatViewController)
        }
    }

    func showChat(appointmentInfo: AppointmentInfo) {
        push(screenFactory.makeChatViewController(appointmentInfo: appointmentInfo))
    }

}
