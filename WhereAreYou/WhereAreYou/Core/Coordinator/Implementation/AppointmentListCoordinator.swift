//
//  AppointmentListCoordinator.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

import UIKit

final class AppointmentListCoordinator: NavigationCoordinator, AppointmentListCoordinating, AppointmentRouteCoordinating {

    let navigationController: UINavigationController
    private let screenFactory: AppointmentListScreenFactory
    private var chatCoordinator: ChatCoordinator?
    private var routeSearchCoordinator: RouteSearchCoordinator?

    init(
        navigationController: UINavigationController,
        screenFactory: ScreenFactory = .shared
    ) {
        self.navigationController = navigationController
        self.screenFactory = screenFactory
    }

    func start() {
        let viewController = screenFactory.makeAppointmentListViewController()
        viewController.coordinator = self
        navigationController.setViewControllers([viewController], animated: false)
    }

    // MARK: - Past Appointment List

    func showPastAppointmentList() {
        let viewController = screenFactory.makePastAppointmentListViewController()
        viewController.coordinator = self
        push(viewController)
    }

    // MARK: - Chat

    func showChat(appointmentID: String) {
        screenFactory.makeChatViewController(appointmentID: appointmentID) { [weak self] result in
            guard let self, case .success(let chatViewController) = result else { return }
            let coordinator = ChatCoordinator(navigationController: self.navigationController)
            self.chatCoordinator = coordinator
            chatViewController.coordinator = coordinator
            self.push(chatViewController)
        }
    }

    // MARK: - Appointment Route

    func showAppointmentRoute(appointmentID: String) {
        let viewController = screenFactory.makeAppointmentRouteViewController(appointmentID: appointmentID)
        viewController.coordinator = self
        present(viewController)
    }

    func showRouteSearch(from presentingViewController: UIViewController, destination: Place?) {
        let coordinator = RouteSearchCoordinator(presentingViewController: presentingViewController, destination: destination)
        routeSearchCoordinator = coordinator
        coordinator.start()
    }

}
