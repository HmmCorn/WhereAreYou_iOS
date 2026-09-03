//
//  MyPageCoordinator.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

import UIKit

final class MyPageCoordinator: NavigationCoordinator {

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
        let viewController = MyPageViewController(
            viewModel: MyPageViewModel(
                observeLocationPermissionUseCase: ObserveLocationPermissionUseCase(
                    repository: screenFactory.container.resolve(LocationPermissionRepository.self)
                )
            )
        )
        viewController.coordinator = self
        navigationController.setViewControllers([viewController], animated: false)
    }

    // MARK: - Profile Edit

    func showProfileEdit(
        nickname: String,
        profileImageName: String,
        onProfileSaved: @escaping (_ nickname: String, _ profileImageName: String) -> Void
    ) {
        let viewController = ProfileEditViewController(nickname: nickname, profileImageName: profileImageName)
        viewController.onProfileSaved = onProfileSaved
        push(viewController)
    }

    // MARK: - Location Sharing Selection

    func showLocationSharingSelection(
        selectedOption: LocationSharingOption,
        onOptionSelected: @escaping (LocationSharingOption) -> Void
    ) {
        let viewController = LocationSharingSelectionViewController(selectedOption: selectedOption)
        viewController.onOptionSelected = onOptionSelected
        push(viewController)
    }

    // MARK: - Location Permission

    func showLocationPermission(viewModel: MyPageViewModel) {
        push(LocationPermissionViewController(viewModel: viewModel))
    }

    // MARK: - Appointment Notification List

    func showAppointmentNotificationList(
        fetchItems: @escaping () -> [AppointmentListItem],
        onToggle: @escaping (String) -> Void
    ) {
        push(AppointmentNotificationListViewController(fetchItems: fetchItems, onToggle: onToggle))
    }

}
