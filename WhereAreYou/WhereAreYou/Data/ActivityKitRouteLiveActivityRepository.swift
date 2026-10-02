//
//  ActivityKitRouteLiveActivityRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-26.
//

import Foundation
import ActivityKit

/// ActivityKit으로 진행 중인 약속 이동 라이브 액티비티를 조회·갱신·종료한다 — 액티비티 모델 → 도메인 모델 변환 포함.
/// 약속 시각을 staleDate로 걸어, 약속 시간이 지나면 시스템이 위젯을 다시 그려 경과 시간을 빨갛게 표시하게 한다.
/// 시작은 3단계에서 서버 push-to-start가 맡으므로, 임시 시작 코드는 DebugLiveActivity 폴더의 `+Start` 확장에 따로 둔다
final class ActivityKitRouteLiveActivityRepository: RouteLiveActivityRepository {

    typealias Attributes = AppointmentRouteActivityAttributes

    func current(appointmentID: String) -> (plan: RouteProgressPlan, status: RouteProgressStatus)? {
        guard let activity = activities(appointmentID: appointmentID).first(where: { Self.isOngoing($0) }) else {
            return nil
        }
        return Self.domainModel(of: activity)
    }

    func update(appointmentID: String, status: RouteProgressStatus) async {
        for activity in activities(appointmentID: appointmentID) {
            await activity.update(content(status: status, attributes: activity.attributes))
        }
    }

    func end(appointmentID: String, status: RouteProgressStatus, dismissalDate: Date) async {
        for activity in activities(appointmentID: appointmentID) {
            await activity.end(
                content(status: status, attributes: activity.attributes),
                dismissalPolicy: .after(dismissalDate)
            )
        }
    }

    private func activities(appointmentID: String) -> [Activity<Attributes>] {
        Activity<Attributes>.activities.filter { $0.attributes.appointmentID == appointmentID }
    }

    /// DebugLiveActivity의 시작 확장도 같은 staleDate 규칙을 쓰도록 internal로 둔다
    func content(status: RouteProgressStatus, attributes: Attributes) -> ActivityContent<Attributes.ContentState> {
        ActivityContent(state: Attributes.ContentState(status: status), staleDate: attributes.appointmentTime)
    }

    /// 약속 시각이 지나 stale이 된 액티비티도 버튼은 계속 눌리므로 종료·제거된 것만 뺀다
    private static func isOngoing(_ activity: Activity<Attributes>) -> Bool {
        activity.activityState == .active || activity.activityState == .stale
    }

    private static func domainModel(of activity: Activity<Attributes>) -> (plan: RouteProgressPlan, status: RouteProgressStatus) {
        (RouteProgressPlan(attributes: activity.attributes), RouteProgressStatus(state: activity.content.state))
    }

}

// MARK: - 도메인 상태 → 액티비티 상태 (갱신·종료용)

private extension AppointmentRouteActivityAttributes.ContentState {

    init(status: RouteProgressStatus) {
        self.init(
            reachedCheckpointCount: status.reachedCheckpointCount,
            arrivedParticipantCount: status.arrivedParticipantCount
        )
    }

}

// MARK: - 액티비티 모델 → 도메인

private extension AppointmentRouteActivityAttributes.Segment.Transport {

    var transportType: TransportType {
        switch self {
        case .walk: return .walk
        case .car: return .car
        case .subway, .bus: return .transit
        }
    }

    var transitVehicle: RouteProgressSegment.TransitVehicle? {
        switch self {
        case .walk, .car: return nil
        case .subway: return .subway
        case .bus: return .bus
        }
    }

}

private extension AppointmentRouteActivityAttributes.Checkpoint.Kind {

    var checkpointKind: RouteCheckpoint.Kind {
        switch self {
        case .departure: return .departure
        case .boarding: return .boarding
        case .alighting: return .alighting
        case .arrival: return .arrival
        }
    }

}

private extension RouteProgressPlan {

    init(attributes: AppointmentRouteActivityAttributes) {
        self.init(
            appointmentID: attributes.appointmentID,
            appointmentName: attributes.appointmentName,
            placeName: attributes.placeName,
            appointmentTime: attributes.appointmentTime,
            participantCount: attributes.participantCount,
            segments: attributes.segments.map { segment in
                RouteProgressSegment(
                    transportType: segment.transport.transportType,
                    transitVehicle: segment.transport.transitVehicle,
                    destinationName: segment.destinationName,
                    estimatedMinutes: segment.estimatedMinutes,
                    lineName: segment.lineName,
                    lineColorHex: segment.lineColorHex,
                    stopCount: segment.stopCount
                )
            },
            checkpoints: attributes.checkpoints.map { checkpoint in
                RouteCheckpoint(
                    kind: checkpoint.kind.checkpointKind,
                    placeName: checkpoint.placeName,
                    scheduledTime: checkpoint.scheduledTime,
                    segmentIndex: checkpoint.segmentIndex
                )
            }
        )
    }

}

private extension RouteProgressStatus {

    init(state: AppointmentRouteActivityAttributes.ContentState) {
        self.init(
            reachedCheckpointCount: state.reachedCheckpointCount,
            arrivedParticipantCount: state.arrivedParticipantCount
        )
    }

}
