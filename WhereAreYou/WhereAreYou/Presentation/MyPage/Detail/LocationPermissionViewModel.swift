//
//  LocationPermissionViewModel.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/7/26.
//

import Combine
import Foundation

final class LocationPermissionViewModel {

    enum LocationPermissionAction {
        case requested
        case shouldOpenSettings
    }

    @Published private(set) var locationPermissionState: LocationPermissionState

    private let observeLocationPermissionUseCase: ObserveLocationPermissionUseCase
    private var cancellables = Set<AnyCancellable>()

    init(observeLocationPermissionUseCase: ObserveLocationPermissionUseCase) {
        self.observeLocationPermissionUseCase = observeLocationPermissionUseCase
        self.locationPermissionState = LocationPermissionState(observeLocationPermissionUseCase.currentStatus)
        bindLocationPermission()
    }

    func requestLocationPermission() {
        observeLocationPermissionUseCase.requestAuthorization()
    }

    func handlePermissionAction() -> LocationPermissionAction {
        if locationPermissionState == .notDetermined {
            requestLocationPermission()
            return .requested
        }
        return .shouldOpenSettings
    }

    private func bindLocationPermission() {
        observeLocationPermissionUseCase.statusPublisher
            .map(LocationPermissionState.init)
            .assign(to: &$locationPermissionState)
    }

}
