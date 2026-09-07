//
//  HomeCoordinator.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

import UIKit

final class HomeCoordinator: NavigationCoordinator, HomeCoordinating, AppointmentCreationCoordinating {

    let navigationController: UINavigationController
    private let screenFactory: HomeScreenFactory
    private var chatCoordinator: ChatCoordinator?

    init(
        navigationController: UINavigationController,
        screenFactory: ScreenFactory = .shared
    ) {
        self.navigationController = navigationController
        self.screenFactory = screenFactory
    }

    func start() {
        let viewController = screenFactory.makeHomeViewController()
        viewController.coordinator = self
        navigationController.setViewControllers([viewController], animated: false)
    }

    // MARK: - Appointment Creation

    func showAppointmentCreation() {
        let viewController = screenFactory.makeAppointmentCreationViewController()
        viewController.coordinator = self
        push(viewController)
    }

    /// 약속 생성 완료 화면에서 확인을 누르면, 생성 화면을 채팅 화면으로 교체한다.
    func replaceAppointmentCreation(
        _ appointmentCreationViewController: UIViewController,
        withChatFor appointmentInfo: AppointmentInfo
    ) {
        let chatViewController = screenFactory.makeChatViewController(appointmentInfo: appointmentInfo)
        let coordinator = ChatCoordinator(navigationController: navigationController)
        chatCoordinator = coordinator
        chatViewController.coordinator = coordinator

        var viewControllers = navigationController.viewControllers
        if let index = viewControllers.firstIndex(of: appointmentCreationViewController) {
            viewControllers[index] = chatViewController
        } else {
            viewControllers.append(chatViewController)
        }
        navigationController.setViewControllers(viewControllers, animated: true)
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

    func showChat(appointmentInfo: AppointmentInfo) {
        let chatViewController = screenFactory.makeChatViewController(appointmentInfo: appointmentInfo)
        let coordinator = ChatCoordinator(navigationController: navigationController)
        chatCoordinator = coordinator
        chatViewController.coordinator = coordinator
        push(chatViewController)
    }

    // MARK: - Place Search / Map Selection (AppointmentCreation 하위)

    func showPlaceSearch(
        selectionButtonTitle: String,
        style: SearchPlaceCardViewController.Style
    ) -> SearchPlaceCardViewController {
        showPlaceSearch(screenFactory: screenFactory, selectionButtonTitle: selectionButtonTitle, style: style)
    }

    func showPlaceMapSelection(initialCoordinate: Coordinate?, onPlaceConfirmed: @escaping (Place) -> Void) {
        let viewController = screenFactory.makePlaceSelectionViewController(initialCoordinate: initialCoordinate)
        viewController.onPlaceConfirmed = onPlaceConfirmed
        viewController.onSearchOtherPlace = { [weak self, weak viewController] onPlaceSelected in
            guard let self else { return }
            let searchPlaceViewController = self.screenFactory.makeSearchPlaceCardViewController(
                selectionButtonTitle: "선택하기",
                style: .onlyHeader(title: "장소 검색")
            )
            searchPlaceViewController.onPlaceSelected = onPlaceSelected
            viewController?.navigationController?.pushViewController(searchPlaceViewController, animated: true)
        }

        presentInNavigationController(viewController) { navigationController in
            navigationController.isModalInPresentation = true
            if let sheet = navigationController.sheetPresentationController {
                sheet.detents = [.large()]
            }
        }
    }

}
