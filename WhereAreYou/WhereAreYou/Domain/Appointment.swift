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
    let place: Place?
    let participants: [User: Route?]
    let placeVoteStatus: [Place: [User]]
    
}
