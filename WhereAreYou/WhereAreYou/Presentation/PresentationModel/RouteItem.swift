//
//  RouteItem.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-17.
//

import Foundation

struct RouteItem {

    let durationText: String
    let departureTimeText: String
    let arrivalTimeText: String
    let steps: [RouteStepItem]

    init(route: Route) {
        let totalMinutes = route.arrivalTime.timeIntervalSince(route.departureTime) / 60
        durationText = RouteStepItem.formatDuration(totalMinutes)
        departureTimeText = route.departureTime.koreanTimeString
        arrivalTimeText = route.arrivalTime.koreanTimeString
        steps = route.step.map(RouteStepItem.init)
    }

}
