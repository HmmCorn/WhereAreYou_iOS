//
//  AppointmentListCoordinator.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

import UIKit

final class AppointmentListCoordinator: NavigationCoordinator {

    let navigationController: UINavigationController
    private let screenFactory: ScreenFactory
    private var chatCoordinator: ChatCoordinator?

    init(
        navigationController: UINavigationController,
        screenFactory: ScreenFactory = ScreenFactory()
    ) {
        self.navigationController = navigationController
        self.screenFactory = screenFactory
    }

    func start() {
        let viewController = AppointmentListViewController()
        viewController.coordinator = self
        navigationController.setViewControllers([viewController], animated: false)
    }

    // MARK: - Past Appointment List

    func showPastAppointmentList() {
        let viewController = PastAppointmentListViewController()
        viewController.coordinator = self
        push(viewController)
    }

    // MARK: - Chat

    func showChat(appointmentID: String) {
        screenFactory.makeChatViewController(appointmentID: appointmentID) { [weak self] result in
            guard let self, case .success(let chatViewController) = result else { return }
            let coordinator = ChatCoordinator(navigationController: self.navigationController, screenFactory: self.screenFactory)
            self.chatCoordinator = coordinator
            chatViewController.coordinator = coordinator
            self.push(chatViewController)
        }
    }

    // MARK: - Appointment Route

    func showAppointmentRoute(appointmentID: String) {
        present(screenFactory.makeAppointmentRouteViewController(appointmentID: appointmentID))
    }

}
