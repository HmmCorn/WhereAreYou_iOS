//
//  MyRouteSummary.swift
//  WhereAreYou
//
//  Created by 김성훈 on 8/5/26.
//

/// 나의 경로 요약을 화면 표시용으로 가공한 값
struct MyRouteSummary {

    let departureTimeText: String
    let arrivalTimeText: String
    let remainingTimeText: String
    let elapsedTimeText: String
    let steps: [RouteStep]

    init(route: Route) {
        departureTimeText = route.departureTime.koreanTimeString
        arrivalTimeText = route.arrivalTime.koreanTimeString
        remainingTimeText = route.arrivalTime.minutesRemainingText
        elapsedTimeText = route.departureTime.elapsedMinutesText
        steps = route.step
    }

}
