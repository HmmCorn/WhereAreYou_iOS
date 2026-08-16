//
//  PlaceInfo.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-16.
//

import UIKit

struct PlaceInfo {

    let id: String
    let name: String
    let address: String
    let coordinate: Coordinate
    let tagTitle: String
    let tagColor: UIColor

    init(place: Place) {
        id = place.id
        name = place.name
        address = place.address
        coordinate = place.coordinate
        tagTitle = place.type.title
        tagColor = place.type.color
    }

}
