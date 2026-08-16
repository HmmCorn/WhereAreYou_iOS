//
//  SharedPlaceItem.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-03.
//

import Foundation

/// 공유된 장소 목록 셀의 표시 정보
struct SharedPlaceItem {

    let id: String
    let placeName: String
    let placeAddress: String
    let voterProfileImages: [String]
    let hasVoted: Bool
    let sharedAt: Date

    init(sharedPlace: SharedPlace, currentUserID: String) {
        id = sharedPlace.id
        placeName = sharedPlace.place.name
        placeAddress = sharedPlace.place.address
        voterProfileImages = sharedPlace.voters.map { $0.profileImageName }
        hasVoted = sharedPlace.voters.contains { $0.id == currentUserID }
        sharedAt = sharedPlace.sharedAt
    }

}
