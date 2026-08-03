//
//  SharedPlaceItem.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-03.
//

import Foundation

struct SharedPlaceItem {
    let id: String
    let placeName: String
    let placeAddress: String
    let voterProfileImages: [String]
    let hasVoted: Bool
    let sharedAt: Date
}
