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
            )
        )
        return MyPageViewController(viewModel: viewModel)
    }

}
