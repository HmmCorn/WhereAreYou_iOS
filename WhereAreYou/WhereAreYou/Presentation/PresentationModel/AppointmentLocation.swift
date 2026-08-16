//
//  AppointmentLocation.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-14.
//

struct AppointmentLocation {

    let title: String
    let address: String
    let coordinate: Coordinate

    init(place: Place) {
        title = place.name
        address = place.address
        coordinate = place.coordinate
    }

    init(title: String, address: String, coordinate: Coordinate) {
        self.title = title
        self.address = address
        self.coordinate = coordinate
    }

}
