//
//  AppointmentInfoRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-06.
//

import Foundation

protocol AppointmentInfoRepository {
    func fetchAppointmentInfo(
        appointmentID: String,
        completion: @escaping (Result<Appointment, Error>) -> Void
    )
    func updateAppointmentInfo(
        appointmentID: String,
        name: String?,
        date: Date?,
        place: Place?,
        completion: @escaping (Result<Appointment, Error>) -> Void
    )
}
