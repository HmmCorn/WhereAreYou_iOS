//
//  RouteCheckpointPlanner.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-26.
//

#if DEBUG
import Foundation

/// [임시 · 3단계에서 서버로 이전] 경로를 확인 지점 목록으로 바꾼다 — 탑승 수단 기준으로 출발 → 첫 탑승역 → 각 하차역 → 도착.
/// 도보·자동차만 있는 경로는 출발 → 도착만 남는다.
/// push-to-start는 앱 코드를 거치지 않으므로 3단계에서는 서버(Functions)가 이 규칙으로 액티비티 데이터를 만든다. 서버 구현의 원본으로 쓴다
enum RouteCheckpointPlanner {

    static func checkpoints(for route: Route, destinationName: String) -> [RouteCheckpoint] {
        let steps = route.step
        guard let firstStep = steps.first else {
            return [
                RouteCheckpoint(kind: .departure, placeName: "", scheduledTime: route.departureTime, segmentIndex: 0),
                RouteCheckpoint(kind: .arrival, placeName: destinationName, scheduledTime: route.arrivalTime, segmentIndex: 0),
            ]
        }

        // 대중교통이 없으면 출발 후 도착까지 묻는 지점이 없다. 주차장까지 걷는 첫 도보 대신 자동차 구간을 현재 구간으로 둔다
        let hasTransit = steps.contains { $0.transportType == .transit }
        let segmentIndexAfterDeparture = hasTransit ? 0 : (steps.firstIndex { $0.transportType == .car } ?? 0)

        var checkpoints = [
            RouteCheckpoint(
                kind: .departure,
                placeName: firstStep.departurePoint.name,
                scheduledTime: route.departureTime,
                segmentIndex: segmentIndexAfterDeparture
            )
        ]

        var elapsedMinutes: Double = 0
        var hasBoarded = false

        for (index, step) in steps.enumerated() {
            let startTime = route.departureTime.addingTimeInterval(elapsedMinutes * 60)
            elapsedMinutes += step.estimatedTime

            guard step.transportType == .transit else { continue }

            // 첫 구간부터 대중교통이면 출발이 곧 탑승이라 따로 묻지 않는다
            if !hasBoarded, index > 0 {
                checkpoints.append(RouteCheckpoint(
                    kind: .boarding,
                    placeName: step.departurePoint.name,
                    scheduledTime: startTime,
                    segmentIndex: index
                ))
            }
            hasBoarded = true

            // 마지막 구간의 하차역은 도착과 같으므로 도착으로만 묻는다
            guard index < steps.count - 1 else { continue }
            checkpoints.append(RouteCheckpoint(
                kind: .alighting,
                placeName: step.destination.name,
                scheduledTime: route.departureTime.addingTimeInterval(elapsedMinutes * 60),
                segmentIndex: segmentIndexAfterAlighting(at: index, in: steps)
            ))
        }

        checkpoints.append(RouteCheckpoint(
            kind: .arrival,
            placeName: destinationName,
            scheduledTime: route.arrivalTime,
            segmentIndex: steps.count
        ))
        return checkpoints
    }

    /// 하차 후 환승 도보를 거쳐 다시 대중교통을 타면, 환승 도보를 건너뛰고 다음 노선 구간을 현재 구간으로 본다.
    /// 환승 탑승은 따로 묻지 않으므로 다음 하차역까지의 안내가 더 쓸모 있다
    private static func segmentIndexAfterAlighting(at index: Int, in steps: [RouteStep]) -> Int {
        let nextIndex = index + 1
        let afterNextIndex = index + 2
        guard afterNextIndex < steps.count,
              steps[nextIndex].transportType == .walk,
              steps[afterNextIndex].transportType == .transit
        else { return nextIndex }
        return afterNextIndex
    }

}
#endif
