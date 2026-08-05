//
//  GetAppointmentDetailUseCase.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/31/26.
//

final class GetAppointmentDetailUseCase {

    private let repository: AppointmentDetailRepository

    init(repository: AppointmentDetailRepository) {
        self.repository = repository
    }

    func execute(
        appointmentID: String,
        completion: @escaping (Result<(appointment: Appointment, currentUserID: String), Error>) -> Void
    ) {
        repository.fetchAppointment(appointmentID: appointmentID, completion: completion)
    }

}
