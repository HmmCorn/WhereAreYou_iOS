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
    /// 목록에서 띄운 지도와 그 약속 — 같은 약속 지도가 이미 떠 있는지 확인하려고 둔다
    private weak var routeViewController: AppointmentRouteViewController?
    private var routeAppointmentID: String?

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
        showChat(appointmentID: appointmentID, sharesLocationImmediately: false)
    }

    private func showChat(appointmentID: String, sharesLocationImmediately: Bool) {
        screenFactory.makeChatViewController(appointmentID: appointmentID) { [weak self] result in
            guard let self, case .success(let chatViewController) = result else { return }
            let coordinator = ChatCoordinator(
                navigationController: self.navigationController,
                appointmentID: appointmentID,
                chatViewController: chatViewController
            )
            self.chatCoordinator = coordinator
            chatViewController.coordinator = coordinator
            if sharesLocationImmediately {
                chatViewController.shareCurrentLocationAfterLoading()
            }
            self.push(chatViewController)
        }
    }

    // MARK: - Appointment Route

    func showAppointmentRoute(appointmentID: String) {
        let viewController = screenFactory.makeAppointmentRouteViewController(appointmentID: appointmentID)
        viewController.coordinator = self
        routeViewController = viewController
        routeAppointmentID = appointmentID
        present(viewController)
    }

    func showRouteSearch(from presentingViewController: UIViewController, destination: Place?) {
        let coordinator = RouteSearchCoordinator(presentingViewController: presentingViewController, destination: destination)
        routeSearchCoordinator = coordinator
        coordinator.start()
    }

}

// MARK: - 라이브 액티비티 딥링크

extension AppointmentListCoordinator: AppointmentDeepLinkHandling {

    /// 목록에서 띄운 같은 약속 지도가 이미 떠 있으면 그대로 두고, 아니면 이 탭에서 연 채팅에 맡긴다
    func handleInPlace(_ deepLink: AppointmentDeepLink) -> Bool {
        if case .route = deepLink,
           routeAppointmentID == deepLink.appointmentID,
           routeViewController?.presentingViewController != nil {
            return true
        }
        return chatCoordinator?.handleInPlace(deepLink) ?? false
    }

    /// 지금 화면에서 처리할 수 없는 딥링크 — 이 탭의 스택을 비우고 목적지를 새로 띄운다
    func showFromDeepLink(_ deepLink: AppointmentDeepLink) {
        navigationController.popToRootViewController(animated: false)
        switch deepLink {
        case .route(let appointmentID):
            showAppointmentRoute(appointmentID: appointmentID)
        case .shareLocation(let appointmentID):
            // 라이브 액티비티의 위치 공유 버튼 — 채팅방을 열면서 확인 없이 내 위치를 바로 보낸다
            showChat(appointmentID: appointmentID, sharesLocationImmediately: true)
        }
    }

}
