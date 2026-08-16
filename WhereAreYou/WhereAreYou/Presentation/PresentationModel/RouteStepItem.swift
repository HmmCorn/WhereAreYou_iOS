//
//  RouteStepItem.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-17.
//

import UIKit

struct RouteStepItem {

    let departureName: String
    let destinationName: String
    let estimatedTimeMinutes: Double
    let durationText: String
    let transportIcon: String
    let transportColor: UIColor

    init(step: RouteStep) {
        departureName = step.departurePoint.name
        destinationName = step.destination.name
        estimatedTimeMinutes = step.estimatedTime
        durationText = Self.formatDuration(step.estimatedTime)
        transportIcon = step.transportType.icon
        transportColor = step.transportType.color
    }

    static func formatDuration(_ minutes: Double) -> String {
        let total = Int(minutes)
        let hours = total / 60
        let mins = total % 60
        if hours > 0 {
            return mins > 0 ? "\(hours)시간 \(mins)분" : "\(hours)시간"
        }
        return "\(mins)분"
    }

}
