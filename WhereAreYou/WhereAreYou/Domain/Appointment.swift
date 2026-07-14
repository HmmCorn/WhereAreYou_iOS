//
//  Appointment.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-14.
//

import Foundation

struct Appointment {

    let id: String
    let code: String
    let name: String
    let dateTime: Date
    let palce: Place?
    let participants: [User: Route?]
    let PlaceVoteStatus: [Place: [User]]
    
}
