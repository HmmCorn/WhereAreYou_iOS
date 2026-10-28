//
//  ScreenFactory+AppointmentList.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/7/26.
//

extension ScreenFactory {

    func makeAppointmentListViewController() -> AppointmentListViewController {
        let viewModel = AppointmentListViewModel(leaveAppointmentUseCase: makeLeaveAppointmentUseCase())
        return AppointmentListViewController(viewModel: viewModel)
    }

    func makePastAppointmentListViewController() -> PastAppointmentListViewController {
        let viewModel = PastAppointmentListViewModel(leaveAppointmentUseCase: makeLeaveAppointmentUseCase())
        return PastAppointmentListViewController(viewModel: viewModel)
    }

    private func makeLeaveAppointmentUseCase() -> LeaveAppointmentUseCase {
        LeaveAppointmentUseCase(repository: container.resolve(AppointmentRepository.self))
    }

}
