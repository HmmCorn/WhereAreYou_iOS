//
//  RouteSearchCoordinator.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

import UIKit

final class RouteSearchCoordinator: NavigationCoordinator, RouteSearchCoordinating {

    let navigationController: UINavigationController
    private let screenFactory: ScreenFactory

    init(screenFactory: ScreenFactory = ScreenFactory()) {
        self.navigationController = UINavigationController()
        self.screenFactory = screenFactory
    }

    func start() {
        // presentModally(from:destination:)를 통해서만 시작되므로 별도 진입점을 갖지 않음
    }

    /// presentingViewController 위에 경로 검색 화면을 모달로 띄운다.
    func presentModally(from presentingViewController: UIViewController, destination: Place?) {
        let viewController = screenFactory.makeRouteSearchViewController(destination: destination)
        viewController.coordinator = self
        navigationController.setViewControllers([viewController], animated: false)
        presentingViewController.present(navigationController, animated: true)
    }

    // MARK: - Place Search

    func showPlaceSearch(
        buttonTitle: String,
        onPlaceSelected: @escaping (Place) -> Void
    ) {
        let viewController = screenFactory.makeSearchPlaceCardViewController(
            selectionButtonTitle: buttonTitle,
            style: .dimmed(title: "장소 검색")
        )
        viewController.onPlaceSelected = onPlaceSelected
        present(viewController)
    }

    // MARK: - Time Picker

    func showTimePicker(initialDate: Date, onDateSelected: @escaping (Date) -> Void) {
        let viewController = DatePickerSheetViewController(
            title: "출발 시간 설정",
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
