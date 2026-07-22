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
    let date: Date?
}
