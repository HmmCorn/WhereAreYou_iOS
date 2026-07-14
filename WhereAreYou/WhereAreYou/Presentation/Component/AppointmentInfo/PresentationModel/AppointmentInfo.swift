//
//  AppointmentInfo.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-14.
//


struct AppointmentInfo {
    let id: String
    let code: String
    let title: String
    let date: Date
    let location: AppointmentLocation
    let participants: [Participant]
}