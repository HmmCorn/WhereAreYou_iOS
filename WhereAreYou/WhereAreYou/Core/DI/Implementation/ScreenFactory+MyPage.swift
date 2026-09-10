//
//  ScreenFactory+MyPage.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

extension ScreenFactory {

    func makeMyPageViewController() -> MyPageViewController {
        let viewModel = MyPageViewModel(
            observeLocationPermissionUseCase: ObserveLocationPermissionUseCase(
                repository: container.resolve(LocationPermissionRepository.self)
            ),
            signOutUseCase: SignOutUseCase(
                authRepository: container.resolve(AuthRepository.self)
            )
        )
        return MyPageViewController(viewModel: viewModel)
    }

    func makeLocationPermissionViewController() -> LocationPermissionViewController {
        let viewModel = LocationPermissionViewModel(
            observeLocationPermissionUseCase: ObserveLocationPermissionUseCase(
                repository: container.resolve(LocationPermissionRepository.self)
            )
        )
        return LocationPermissionViewController(viewModel: viewModel)
    }

}
