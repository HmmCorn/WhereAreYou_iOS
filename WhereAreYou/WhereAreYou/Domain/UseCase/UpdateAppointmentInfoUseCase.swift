//
//  UpdateAppointmentInfoUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-06.
//

import Foundation

final class UpdateAppointmentInfoUseCase {

    private let repository: AppointmentInfoRepository

    init(repository: AppointmentInfoRepository) {
        self.repository = repository
    }

    func execute(
        appointmentID: String,
        name: String?,
        date: Date?,
        place: Place?,
        completion: @escaping (Result<Appointment, Error>) -> Void
    ) {
        repository.updateAppointmentInfo(
            appointmentID: appointmentID,
            name: name,
            date: date,
            place: place,
            completion: completion
        )
    }

}
