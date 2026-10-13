//
//  Place.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-14.
//

struct Place: Hashable {

    let id: String
    let name: String
    let address: String
    let coordinate: Coordinate
    let type: PlaceType

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Place, rhs: Place) -> Bool {
        lhs.id == rhs.id
    }

}
