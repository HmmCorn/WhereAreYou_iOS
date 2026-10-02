//
//  AppointmentRouteDisplay.swift
//  WhereAreYouWidget
//
//  Created by 이상유 on 2026-09-26.
//

import Foundation

/// 라이브 액티비티에 보여줄 문구와 진행 위치 계산 — 속성(고정)과 상태(변경)를 합쳐 한 화면 분량의 값을 만든다
struct AppointmentRouteDisplay {

    let attributes: AppointmentRouteActivityAttributes
    let state: AppointmentRouteActivityAttributes.ContentState
    /// 약속 시간이 지났는지. staleDate(약속 시각)가 지나 시스템이 다시 그렸거나, 그리는 시점에 이미 지난 경우
    let isPastAppointmentTime: Bool

    var isArrived: Bool {
        state.reachedCheckpointCount >= attributes.checkpoints.count
    }

    var hasDeparted: Bool {
        state.reachedCheckpointCount > 0
    }

    /// 다음에 물어볼 확인 지점. 도착했으면 nil
    var nextCheckpoint: AppointmentRouteActivityAttributes.Checkpoint? {
        attributes.checkpoints.indices.contains(state.reachedCheckpointCount)
            ? attributes.checkpoints[state.reachedCheckpointCount]
            : nil
    }

    /// 지금 이동 중인 구간. 출발 전이면 nil, 도착했으면 구간 수와 같다
    var currentSegmentIndex: Int? {
        guard hasDeparted else { return nil }
        let lastReachedIndex = min(state.reachedCheckpointCount, attributes.checkpoints.count) - 1
        return attributes.checkpoints[lastReachedIndex].segmentIndex
    }

    var currentSegment: AppointmentRouteActivityAttributes.Segment? {
        guard let currentSegmentIndex, attributes.segments.indices.contains(currentSegmentIndex) else { return nil }
        return attributes.segments[currentSegmentIndex]
    }

    var arrivalText: String {
        "\(state.arrivedParticipantCount)/\(attributes.participantCount) 도착"
    }

    var appointmentSummaryText: String {
        "\(Self.timeFormatter.string(from: attributes.appointmentTime)) · \(attributes.placeName)"
    }

    /// 현재 구간 1줄 — "강남역까지 4정거장", "이수역까지 도보 6분"
    var statusText: String {
        if isArrived { return "도착했어요" }
        guard hasDeparted else {
            let departureTime = attributes.checkpoints.first?.scheduledTime ?? attributes.appointmentTime
            return "\(Self.timeFormatter.string(from: departureTime)) 출발 예정"
        }
        guard let segment = currentSegment else { return "" }

        switch segment.transport {
        case .subway, .bus:
            if let stopCount = segment.stopCount {
                return "\(segment.destinationName)까지 \(stopCount)정거장"
            }
            return "\(segment.destinationName)까지 \(segment.estimatedMinutes)분"
        case .walk:
            return "\(segment.destinationName)까지 도보 \(segment.estimatedMinutes)분"
        case .car:
            return "\(segment.destinationName)까지 차로 \(segment.estimatedMinutes)분"
        }
    }

    var nextQuestionText: String? {
        guard let nextCheckpoint else { return nil }
        switch nextCheckpoint.kind {
        case .departure: return "출발했나요?"
        case .boarding, .alighting: return "\(nextCheckpoint.placeName)에 도착했나요?"
        case .arrival: return "도착했나요?"
        }
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm"
        return formatter
    }()

}
