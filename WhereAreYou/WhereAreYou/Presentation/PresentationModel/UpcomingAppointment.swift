//
//  UpcomingAppointment.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/16/26.
//

import Foundation

struct UpcomingAppointment {
    let id: String
    let title: String
    let participantCount: Int
    let location: AppointmentLocation?
    let date: Date

    init(appointment: Appointment) {
        id = appointment.id
        title = appointment.name
        participantCount = appointment.participants.count
        location = appointment.place.map { AppointmentLocation(place: $0) }
        date = appointment.dateTime
    }

}
