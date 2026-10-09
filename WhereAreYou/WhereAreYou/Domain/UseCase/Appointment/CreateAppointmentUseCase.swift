//
//  CreateAppointmentUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-24.
//

import Foundation

final class CreateAppointmentUseCase {

    private let repository: AppointmentCreationRepository

    init(repository: AppointmentCreationRepository) {
        self.repository = repository
    }

    func execute(
        title: String,
        date: Date?,
        place: Place?,
        completion: @escaping (Result<Appointment, Error>) -> Void
    ) {
        repository.createAppointment(
            title: title,
            date: date,
            place: place,
            completion: completion
        )
    }

}
