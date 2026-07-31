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
        appointmentId: String,
        completion: @escaping (Result<(appointment: Appointment, currentUserId: String), Error>) -> Void
    ) {
        repository.fetchAppointment(appointmentId: appointmentId, completion: completion)
    }

}
