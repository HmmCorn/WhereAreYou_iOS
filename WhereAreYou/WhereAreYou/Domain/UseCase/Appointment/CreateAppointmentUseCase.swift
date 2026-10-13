//
//  CreateAppointmentUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-24.
//

import Foundation

final class CreateAppointmentUseCase {

    private let repository: AppointmentRepository

    init(repository: AppointmentRepository) {
        self.repository = repository
    }

    func execute(name: String, dateTime: Date, place: Place?) async throws -> Appointment {
        try await repository.createAppointment(name: name, dateTime: dateTime, place: place)
    }

}
