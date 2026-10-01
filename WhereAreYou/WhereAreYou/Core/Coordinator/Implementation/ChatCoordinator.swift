//
//  ChatCoordinator.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

import UIKit

final class ChatCoordinator: NavigationCoordinator, DatePickerPresenting, PlaceSearchPresenting, ChatCoordinating, AppointmentInfoCoordinating, AppointmentRouteCoordinating {

    let navigationController: UINavigationController
    private let screenFactory: ChatScreenFactory
    private var routeSearchCoordinator: RouteSearchCoordinator?

    /// 이 코디네이터가 맡은 채팅의 약속 — 딥링크가 같은 약속인지 판단할 때 쓴다
    private let appointmentID: String
    /// 채팅이 지금 화면 맨 위에 있는지 확인하려고 둔다. 소유는 내비게이션 스택이 한다
    private weak var chatViewController: ChatViewController?
    /// 같은 약속 지도가 이미 떠 있는지 확인하려고 둔다
    private weak var routeViewController: AppointmentRouteViewController?

    init(
        navigationController: UINavigationController,
        appointmentID: String,
        chatViewController: ChatViewController,
        screenFactory: ScreenFactory = .shared
    ) {
        self.navigationController = navigationController
        self.appointmentID = appointmentID
        self.chatViewController = chatViewController
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
        routeViewController = viewController
        present(viewController)
    }

    func showRouteSearch(from presentingViewController: UIViewController, destination: Place?) {
        let coordinator = RouteSearchCoordinator(presentingViewController: presentingViewController, destination: destination)
        routeSearchCoordinator = coordinator
        coordinator.start()
    }

    // MARK: - Location Preview

    func showLocationPreview(title: String, subtitle: String?, coordinate: Coordinate, accentColor: ColorAsset) {
        let viewController = screenFactory.makeLocationPreviewViewController(
            title: title,
            subtitle: subtitle,
            coordinate: coordinate,
            accentColor: accentColor
        )
        present(viewController)
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

// MARK: - 라이브 액티비티 딥링크

extension ChatCoordinator: AppointmentDeepLinkHandling {

    /// 내 채팅이 맨 위에 있고 같은 약속일 때만 처리한다 — 채팅을 다시 만들지 않아 입력 중이던 내용이 유지된다
    func handleInPlace(_ deepLink: AppointmentDeepLink) -> Bool {
        guard deepLink.appointmentID == appointmentID,
              let chatViewController,
              navigationController.topViewController === chatViewController
        else { return false }

        switch deepLink {
        case .route:
            // 같은 약속 지도가 이미 떠 있으면 그대로 둔다
            guard routeViewController?.presentingViewController == nil else { return true }
            dismissPresented { [weak self] in
                guard let self else { return }
                self.showAppointmentRoute(appointmentID: self.appointmentID)
            }
        case .shareLocation:
            dismissPresented {
                chatViewController.shareCurrentLocationAfterLoading()
            }
        }
        return true
    }

}
