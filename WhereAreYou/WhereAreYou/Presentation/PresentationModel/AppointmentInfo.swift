//
//  AppointmentInfo.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-14.
//

import Foundation

struct AppointmentInfo {

    let id: String
    let code: String
    let title: String
    let date: Date?
    let location: AppointmentLocation?
    let participants: [Participant]

    init(appointment: Appointment) {
        id = appointment.id
        code = appointment.code
        title = appointment.name
        date = appointment.dateTime
        location = appointment.place.map { AppointmentLocation(place: $0) }
        participants = appointment.participants.map { Participant(user: $0) }
    }

    /// 약속 생성 화면처럼 아직 Appointment가 만들어지기 전 단계에서 사용
    init(
        id: String,
        code: String,
        title: String,
        date: Date?,
        location: AppointmentLocation?,
        participants: [Participant]
    ) {
        self.id = id
        self.code = code
        self.title = title
        self.date = date
        self.location = location
        self.participants = participants
    }

}
