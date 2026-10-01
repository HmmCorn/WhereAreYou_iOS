//
//  StartRouteLiveActivityUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-26.
//

#if DEBUG
import Foundation

/// [임시 · 3단계에서 삭제] 약속과 내 경로로 확인 지점을 만들어 라이브 액티비티를 시작한다.
/// 3단계에서는 서버가 같은 일을 해서 push-to-start로 보낸다. 그 전까지 DEBUG 메뉴에서만 쓴다.
/// 실시간 현황이 꺼져 있으면 permissionDenied, 내 경로나 약속 장소가 없으면 notFound
final class StartRouteLiveActivityUseCase {

    private let appointmentDetailRepository: AppointmentDetailRepository
    private let liveActivityRepository: RouteLiveActivityStarting
    private let permissionRepository: LiveActivityPermissionRepository

    init(
        appointmentDetailRepository: AppointmentDetailRepository,
        liveActivityRepository: RouteLiveActivityStarting,
        permissionRepository: LiveActivityPermissionRepository
    ) {
        self.appointmentDetailRepository = appointmentDetailRepository
        self.liveActivityRepository = liveActivityRepository
        self.permissionRepository = permissionRepository
    }

    func execute(appointmentID: String) async throws {
        guard permissionRepository.authorizationStatus == .allowed else {
            throw AppError.permissionDenied
        }

        let (appointment, currentUserID) = try await fetchAppointment(appointmentID: appointmentID)
        guard let route = appointment.routes[currentUserID], let place = appointment.place else {
            throw AppError.notFound
        }

        let plan = RouteProgressPlan(
            appointmentID: appointment.id,
            appointmentName: appointment.name,
            placeName: place.name,
            appointmentTime: appointment.dateTime,
            participantCount: appointment.participants.count,
            segments: route.step.map(RouteProgressSegment.init(step:)),
            checkpoints: RouteCheckpointPlanner.checkpoints(for: route, destinationName: place.name)
        )
        try await liveActivityRepository.start(
            plan: plan,
            status: RouteProgressStatus(reachedCheckpointCount: 0, arrivedParticipantCount: 0)
        )
    }

    private func fetchAppointment(appointmentID: String) async throws -> (Appointment, String) {
        try await withCheckedThrowingContinuation { continuation in
            appointmentDetailRepository.fetchAppointment(appointmentID: appointmentID) { result in
                continuation.resume(with: result.map { ($0.appointment, $0.currentUserID) })
            }
        }
    }

}
#endif
