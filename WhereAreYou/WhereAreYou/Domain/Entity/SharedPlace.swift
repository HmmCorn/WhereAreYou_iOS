//
//  SharedPlace.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-03.
//

import Foundation

struct SharedPlace {
    let id: String
    let place: Place
    let sharedBy: User
    let sharedAt: Date
    var voters: [User]
}
