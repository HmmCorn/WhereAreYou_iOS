//
//  HomeCoordinator.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

import UIKit

final class HomeCoordinator: NavigationCoordinator, HomeCoordinating, AppointmentCreationCoordinating {

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
        let viewController = HomeViewController()
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
        let coordinator = ChatCoordinator(navigationController: navigationController, screenFactory: screenFactory)
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
            let coordinator = ChatCoordinator(navigationController: self.navigationController, screenFactory: self.screenFactory)
            self.chatCoordinator = coordinator
            chatViewController.coordinator = coordinator
            self.push(chatViewController)
        }
    }

    func showChat(appointmentInfo: AppointmentInfo) {
        let chatViewController = screenFactory.makeChatViewController(appointmentInfo: appointmentInfo)
        let coordinator = ChatCoordinator(navigationController: navigationController, screenFactory: screenFactory)
        chatCoordinator = coordinator
        chatViewController.coordinator = coordinator
        push(chatViewController)
    }

    // MARK: - Place Search / Map Selection (AppointmentCreation 하위)

    func showPlaceSearch(
        selectionButtonTitle: String,
        style: SearchPlaceCardViewController.Style
    ) -> SearchPlaceCardViewController {
        let viewController = screenFactory.makeSearchPlaceCardViewController(
            selectionButtonTitle: selectionButtonTitle,
            style: style
        )
        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        present(viewController)
        return viewController
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

    func showDatePicker(initialDate: Date?, onDateSelected: @escaping (Date) -> Void) {
        let viewController = DatePickerSheetViewController(
            title: "약속 날짜/시간 설정",
            initialDate: initialDate
        )
        viewController.onDateSelected = onDateSelected

        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        present(viewController)
    }

}
