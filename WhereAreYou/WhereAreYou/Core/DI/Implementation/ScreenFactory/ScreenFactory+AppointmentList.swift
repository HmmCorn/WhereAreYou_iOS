//
//  ScreenFactory+AppointmentList.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/7/26.
//

extension ScreenFactory {

    func makeAppointmentListViewController() -> AppointmentListViewController {
        let viewModel = AppointmentListViewModel(
            fetchMyAppointmentsUseCase: FetchMyAppointmentsUseCase(
                repository: container.resolve(AppointmentRepository.self)
            ),
            leaveAppointmentUseCase: LeaveAppointmentUseCase(
                repository: container.resolve(AppointmentRepository.self)
            )
        )
        return AppointmentListViewController(viewModel: viewModel)
    }

    func makePastAppointmentListViewController() -> PastAppointmentListViewController {
        let viewModel = PastAppointmentListViewModel(
            fetchMyAppointmentsUseCase: FetchMyAppointmentsUseCase(
                repository: container.resolve(AppointmentRepository.self)
            ),
            leaveAppointmentUseCase: LeaveAppointmentUseCase(
                repository: container.resolve(AppointmentRepository.self)
            )
        )
        return PastAppointmentListViewController(viewModel: viewModel)
    }

}
