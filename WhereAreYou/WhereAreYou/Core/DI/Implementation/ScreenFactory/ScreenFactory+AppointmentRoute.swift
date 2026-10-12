//
//  ScreenFactory+AppointmentRoute.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

extension ScreenFactory {

    func makeAppointmentRouteViewController(appointmentID: String) -> AppointmentRouteViewController {
        let viewModel = AppointmentRouteViewModel(
            appointmentID: appointmentID,
            getAppointmentDetailUseCase: GetAppointmentDetailUseCase(
                appointmentRepository: container.resolve(AppointmentRepository.self),
                appointmentRouteRepository: container.resolve(AppointmentRouteRepository.self),
                authRepository: container.resolve(AuthRepository.self)
            )
        )
        return AppointmentRouteViewController(viewModel: viewModel)
    }

}
