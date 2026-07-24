//
//  User.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-14.
//

import Foundation

struct User: Hashable {

    let id: String
    let nickname: String
    let profileImage: URL
    let defaultTransportMode: TransportType
    let locationSharingScope: LocationSharingScope
    let isNotificationEnabled: Bool
    let appointmentsNotification: [String: Bool]

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }

}
