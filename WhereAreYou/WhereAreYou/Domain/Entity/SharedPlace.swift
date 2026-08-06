//
//  SharedPlace.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-03.
//

import Foundation

/// 약속에 공유된 장소 — 투표자 목록 포함
struct SharedPlace {
    let id: String
    let appointmentID: String
    let place: Place
    let sharedBy: User
    let sharedAt: Date
    var voters: [User]
}
