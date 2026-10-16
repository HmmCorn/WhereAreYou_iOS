//
//  ScreenFactory+Home.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

extension ScreenFactory {

    func makeHomeViewController() -> HomeViewController {
        let viewModel = HomeViewModel(
            joinAppointmentUseCase: JoinAppointmentUseCase(
                repository: container.resolve(AppointmentRepository.self)
            )
        )
        return HomeViewController(viewModel: viewModel)
    }

}
