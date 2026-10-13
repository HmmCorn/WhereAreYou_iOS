//
//  FetchAppointmentInfoUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-06.
//

final class FetchAppointmentInfoUseCase {

    private let repository: AppointmentRepository

    init(repository: AppointmentRepository) {
        self.repository = repository
    }

    func execute(appointmentID: String) async throws -> Appointment {
        try await repository.fetchAppointment(appointmentID: appointmentID)
    }

}
