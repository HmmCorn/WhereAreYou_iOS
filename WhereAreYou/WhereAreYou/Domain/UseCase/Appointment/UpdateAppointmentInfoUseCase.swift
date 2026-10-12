//
//  UpdateAppointmentInfoUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-06.
//

import Foundation

final class UpdateAppointmentInfoUseCase {

    private let repository: AppointmentRepository

    init(repository: AppointmentRepository) {
        self.repository = repository
    }

    func execute(
        appointmentID: String,
        name: String?,
        dateTime: Date?,
        place: Place?
    ) async throws -> Appointment {
        try await repository.updateAppointment(
            appointmentID: appointmentID,
            name: name,
            dateTime: dateTime,
            place: place
        )
    }

}
