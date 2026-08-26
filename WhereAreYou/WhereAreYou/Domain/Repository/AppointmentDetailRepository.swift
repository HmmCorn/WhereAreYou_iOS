//
//  AppointmentDetailRepository.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/31/26.
//

import Foundation

protocol AppointmentDetailRepository {

    func fetchAppointment(
        appointmentID: String,
        completion: @escaping (Result<(appointment: Appointment, currentUserID: String), Error>) -> Void
    )

    func fetchAppointment(
        code: String,
        completion: @escaping (Result<(appointment: Appointment, currentUserID: String), Error>) -> Void
    )

}
