//
//  RouteStepItem.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-17.
//

import Foundation

struct RouteStepItem {

    /// 구간 문구 (예: "4호선 서울역 > 충무로", "충무로 환승", "서울역까지 도보")
    let title: String
    let estimatedTimeMinutes: Double
    let durationText: String
    let transportIcon: String
    let transportColor: ColorAsset

    init(step: RouteStep, title: String) {
        self.title = title
        estimatedTimeMinutes = step.estimatedTime
        durationText = Self.formatDuration(step.estimatedTime)
        transportIcon = step.transportType.icon
        transportColor = step.transportType.color
    }

    /// 경로의 구간 아이템 목록, 앞뒤 구간을 보고 문구 결정
    static func items(of route: Route) -> [RouteStepItem] {
        let steps = route.step
        return steps.indices.map { index in
            let previous = index > 0 ? steps[index - 1] : nil
            let next = index < steps.count - 1 ? steps[index + 1] : nil
            return RouteStepItem(
                step: steps[index],
                title: title(of: steps[index], previous: previous, next: next, isOnlyStep: steps.count == 1)
            )
        }
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

    // MARK: - Private

    /// 구간 종류와 앞뒤 구간에 따른 문구
    private static func title(of step: RouteStep, previous: RouteStep?, next: RouteStep?, isOnlyStep: Bool) -> String {
        let departureName = step.departurePoint.name
        let destinationName = step.destination.name
        let section = "\(departureName) > \(destinationName)"

        if isOnlyStep {
            return section
        }

        switch step.transportType {
        case .transit:
            return step.lineName.map { "\($0) \(section)" } ?? section
        case .walk:
            let isTransfer = previous?.transportType == .transit && next?.transportType == .transit
            guard isTransfer else { return "\(destinationName)까지 도보" }
            return departureName == destinationName ? "\(destinationName) 환승" : "\(destinationName)까지 도보 환승"
        case .car:
            return section
        }
    }

}
