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
    let transportName: String
    let transportIcon: String
    let transportColor: ColorAsset
    let departureTimeText: String
    let arrivalTimeText: String

    init(
        user: User,
        route: Route,
        currentUserID: String
    ) {
        let transport = route.step.last?.transportType ?? user.defaultTransportMode
        id = user.id
        nickname = user.nickname
        profileImageURL = user.profileImage
        isMe = user.id == currentUserID
        path = route.step.flatMap(\.path)
        transportName = transport.name
        transportIcon = transport.icon
        transportColor = transport.color
        departureTimeText = route.departureTime.koreanTimeString
        arrivalTimeText = route.arrivalTime.koreanTimeString
    }

}
