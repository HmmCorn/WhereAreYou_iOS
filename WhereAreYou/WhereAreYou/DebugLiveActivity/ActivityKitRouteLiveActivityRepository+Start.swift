//
//  ActivityKitRouteLiveActivityRepository+Start.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-27.
//

#if DEBUG
import Foundation
import ActivityKit

/// [임시 · 3단계에서 삭제] ActivityKit으로 라이브 액티비티를 시작한다 — 도메인 모델 → 액티비티 모델 변환 포함.
/// 3단계에서는 서버가 이 변환 결과와 같은 형식으로 push-to-start 페이로드를 만든다
extension ActivityKitRouteLiveActivityRepository: RouteLiveActivityStarting {

    func start(plan: RouteProgressPlan, status: RouteProgressStatus) async throws {
        for activity in Activity<Attributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }

        let attributes = Attributes(plan: plan)
        do {
            _ = try Activity.request(
                attributes: attributes,
                content: content(status: status, attributes: attributes),
                pushType: nil
            )
        } catch {
            throw AppError.unknown(error)
        }
    }

}

// MARK: - 도메인 → 액티비티 모델

private extension AppointmentRouteActivityAttributes {

    init(plan: RouteProgressPlan) {
        self.init(
            appointmentID: plan.appointmentID,
            appointmentName: plan.appointmentName,
            placeName: plan.placeName,
            appointmentTime: plan.appointmentTime,
            participantCount: plan.participantCount,
            segments: plan.segments.map { segment in
                Segment(
                    transport: Segment.Transport(segment.transportType, vehicle: segment.transitVehicle),
                    destinationName: segment.destinationName,
                    estimatedMinutes: segment.estimatedMinutes,
                    lineName: segment.lineName,
                    lineColorHex: segment.lineColorHex,
                    stopCount: segment.stopCount
                )
            },
            checkpoints: plan.checkpoints.map { checkpoint in
                Checkpoint(
                    kind: Checkpoint.Kind(checkpoint.kind),
                    placeName: checkpoint.placeName,
                    scheduledTime: checkpoint.scheduledTime,
                    segmentIndex: checkpoint.segmentIndex
                )
            }
        )
    }

}

private extension AppointmentRouteActivityAttributes.Segment.Transport {

    init(_ transportType: TransportType, vehicle: RouteProgressSegment.TransitVehicle?) {
        switch transportType {
        case .walk: self = .walk
        case .car: self = .car
        case .transit: self = vehicle == .bus ? .bus : .subway
        }
    }

}

private extension AppointmentRouteActivityAttributes.Checkpoint.Kind {

    init(_ kind: RouteCheckpoint.Kind) {
        switch kind {
        case .departure: self = .departure
        case .boarding: self = .boarding
        case .alighting: self = .alighting
        case .arrival: self = .arrival
        }
    }

}
#endif
