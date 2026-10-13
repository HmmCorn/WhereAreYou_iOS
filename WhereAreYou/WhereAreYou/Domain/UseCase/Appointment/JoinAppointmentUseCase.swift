//
//  JoinAppointmentUseCase.swift
//  WhereAreYou
//
//  Created by 김성훈 on 8/26/26.
//

final class JoinAppointmentUseCase {

    private let repository: AppointmentRepository

    init(repository: AppointmentRepository) {
        self.repository = repository
    }

    func execute(code: String) async throws -> Appointment {
        try await repository.joinAppointment(code: code)
    }

}
