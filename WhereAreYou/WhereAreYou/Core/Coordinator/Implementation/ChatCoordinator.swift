//
//  ChatCoordinator.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

import UIKit

final class ChatCoordinator: NavigationCoordinator, ChatCoordinating, AppointmentInfoCoordinating, AppointmentRouteCoordinating {

    let navigationController: UINavigationController
    private let screenFactory: ScreenFactory
    private var routeSearchCoordinator: RouteSearchCoordinator?

    init(
        navigationController: UINavigationController,
        screenFactory: ScreenFactory = .shared
    ) {
        self.navigationController = navigationController
        self.screenFactory = screenFactory
    }

    func start() {
        // Chat 화면은 Home/AppointmentList Coordinator가 makeChatVC로 조립해 push하므로,
        // 이 Coordinator는 별도의 진입점(start)을 갖지 않음
    }

    // MARK: - Appointment Route

    func showAppointmentRoute(appointmentID: String) {
        let viewController = screenFactory.makeAppointmentRouteViewController(appointmentID: appointmentID)
        viewController.coordinator = self
        present(viewController)
    }

    func showRouteSearch(from presentingViewController: UIViewController, destination: Place?) {
        let coordinator = RouteSearchCoordinator()
        routeSearchCoordinator = coordinator
        coordinator.presentModally(from: presentingViewController, destination: destination)
    }

    // MARK: - Appointment Info

    func showAppointmentInfo(appointmentID: String) {
        let viewController = screenFactory.makeAppointmentInfoViewController(appointmentID: appointmentID)
        viewController.coordinator = self
        present(viewController, animated: false)
    }

    // MARK: - Share My Location

    func showShareMyLocationConfirm(address: String, onConfirm: @escaping () -> Void) {
        let viewController = ShareMyLocationViewController(address: address)
        viewController.onConfirm = onConfirm
        present(viewController)
    }

    // MARK: - Search Place (장소 공유 / 약속 장소 검색 공용)

    func showPlaceSearch(
        selectionButtonTitle: String,
        style: SearchPlaceCardViewController.Style
    ) -> SearchPlaceCardViewController {
        showPlaceSearch(screenFactory: screenFactory, selectionButtonTitle: selectionButtonTitle, style: style)
    }

    // MARK: - Shared Places

    func showSharedPlaces(appointmentID: String, currentUserID: String) {
        let viewController = screenFactory.makeSharedPlacesViewController(
            appointmentID: appointmentID,
            currentUserID: currentUserID
        )

        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        present(viewController)
    }

    // MARK: - Place Map Selection (AppointmentInfo 하위)

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
