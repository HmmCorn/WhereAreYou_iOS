//
//  JoinAppointmentUseCase.swift
//  WhereAreYou
//
//  Created by 김성훈 on 8/26/26.
//

final class JoinAppointmentUseCase {

    private let repository: AppointmentDetailRepository

    init(repository: AppointmentDetailRepository) {
        self.repository = repository
    }

    func execute(
        code: String,
        completion: @escaping (Result<(appointment: Appointment, currentUserID: String), Error>) -> Void
    ) {
        repository.fetchAppointment(code: code, completion: completion)
    }

}
