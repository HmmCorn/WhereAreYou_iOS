//
//  AppointmentCreationRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-24.
//

import Foundation

protocol AppointmentCreationRepository {

    func createAppointment(
        title: String,
        date: Date?,
        place: Place?,
        completion: @escaping (Result<Appointment, Error>) -> Void
    )

}
