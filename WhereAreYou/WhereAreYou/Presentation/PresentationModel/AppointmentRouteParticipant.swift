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

    init(
        id: String,
        nickname: String,
        profileImageURL: URL,
        isMe: Bool,
        path: [Coordinate],
        transportType: TransportType,
        departureTimeText: String,
        arrivalTimeText: String
    ) {
        self.id = id
        self.nickname = nickname
        self.profileImageURL = profileImageURL
        self.isMe = isMe
        self.path = path
        self.transportType = transportType
        self.departureTimeText = departureTimeText
        self.arrivalTimeText = arrivalTimeText
    }

    init(
        user: User,
        route: Route,
        currentUserId: String
    ) {
        self.init(
            id: user.id,
            nickname: user.nickname,
            profileImageURL: user.profileImage,
            isMe: user.id == currentUserId,
            path: route.step.flatMap(\.path),
            transportType: route.step.last?.transportType ?? user.defaultTransportMode,
            departureTimeText: route.departureTime.koreanTimeString,
            arrivalTimeText: route.arrivalTime.koreanTimeString
        )
    }

}
