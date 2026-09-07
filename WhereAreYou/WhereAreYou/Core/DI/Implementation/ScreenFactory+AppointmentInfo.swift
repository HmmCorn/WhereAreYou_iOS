//
//  ScreenFactory+AppointmentInfo.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

extension ScreenFactory {

    func makeAppointmentInfoViewController(appointmentID: String) -> AppointmentInfoViewController {
        let repository = container.resolve(AppointmentInfoRepository.self)
        let viewModel = AppointmentInfoViewModel(
            appointmentID: appointmentID,
            fetchAppointmentInfoUseCase: FetchAppointmentInfoUseCase(repository: repository),
            updateAppointmentInfoUseCase: UpdateAppointmentInfoUseCase(repository: repository)
        )
        return AppointmentInfoViewController(viewModel: viewModel)
    }

}
