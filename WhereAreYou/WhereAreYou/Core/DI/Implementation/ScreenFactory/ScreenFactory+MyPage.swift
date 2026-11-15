//
//  ScreenFactory+MyPage.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

extension ScreenFactory {

    func makeMyPageViewController() -> MyPageViewController {
        let authRepository = container.resolve(AuthRepository.self)
        let userRepository = container.resolve(UserRepository.self)
        let viewModel = MyPageViewModel(
            fetchMyUserUseCase: FetchMyUserUseCase(
                authRepository: authRepository,
                userRepository: userRepository
            ),
            updateMyUserUseCase: UpdateMyUserUseCase(
                authRepository: authRepository,
                userRepository: userRepository
            ),
            fetchMyAppointmentsUseCase: FetchMyAppointmentsUseCase(
                repository: container.resolve(AppointmentRepository.self)
            ),
            observeLocationPermissionUseCase: ObserveLocationPermissionUseCase(
                repository: container.resolve(LocationPermissionRepository.self)
            ),
            observeLiveActivityPermissionUseCase: ObserveLiveActivityPermissionUseCase(
                repository: container.resolve(LiveActivityPermissionRepository.self)
            ),
            signOutUseCase: SignOutUseCase(
                authRepository: authRepository,
                fcmInstallationIDRepository: container.resolve(FCMInstallationIDRepository.self)
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
