//
//  ScreenFactory+AppointmentCreation.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

extension ScreenFactory {

    func makeAppointmentCreationViewController() -> AppointmentCreationViewController {
        let viewModel = AppointmentCreationViewModel(
            createAppointmentUseCase: CreateAppointmentUseCase(
                repository: container.resolve(AppointmentCreationRepository.self)
            )
        )
        return AppointmentCreationViewController(viewModel)
    }

}
