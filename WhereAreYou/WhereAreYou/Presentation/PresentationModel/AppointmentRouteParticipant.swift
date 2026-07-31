//
//  AppointmentRouteParticipant.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/31/26.
//

import Foundation

struct AppointmentRouteParticipant {

    let id: String
    let nickname: String
    let profileImageURL: URL
    let isMe: Bool
    let path: [Coordinate]
    let transportType: TransportType
    let departureTimeText: String
    let arrivalTimeText: String

}
