//
//  RouteSearchCoordinator.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

import UIKit

final class RouteSearchCoordinator: NavigationCoordinator, DatePickerPresenting, RouteSearchCoordinating {

    let navigationController: UINavigationController
    private let screenFactory: RouteSearchScreenFactory
    private weak var presentingViewController: UIViewController?
    private let destination: Place?

    init(
        presentingViewController: UIViewController,
        destination: Place?,
        screenFactory: ScreenFactory = .shared
    ) {
        self.navigationController = UINavigationController()
        self.presentingViewController = presentingViewController
        self.destination = destination
        self.screenFactory = screenFactory
    }

    /// presentingViewController 위에 경로 검색 화면을 모달로 띄운다.
    func start() {
        let viewController = screenFactory.makeRouteSearchViewController(departure: nil, destination: destination)
        viewController.coordinator = self
        navigationController.setViewControllers([viewController], animated: false)
        presentingViewController?.present(navigationController, animated: true)
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

}
