//
//  AppointmentDetailRepository.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/31/26.
//

import Foundation

protocol AppointmentDetailRepository {

    func fetchAppointment(
        appointmentId: String,
        completion: @escaping (Result<(appointment: Appointment, currentUserId: String), Error>) -> Void
    )

}
