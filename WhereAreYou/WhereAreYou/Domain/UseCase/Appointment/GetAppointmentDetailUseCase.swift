//
//  GetAppointmentDetailUseCase.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/31/26.
//

/// 경로 지도용 약속 상세 — 약속 문서와 참여자별 경로를 함께 조회하고 현재 사용자 ID를 붙인다.
/// 로그인 정보가 없으면 AppError.notAuthenticated
final class GetAppointmentDetailUseCase {

    private let appointmentRepository: AppointmentRepository
    private let appointmentRouteRepository: AppointmentRouteRepository
    private let authRepository: AuthRepository

    init(
        appointmentRepository: AppointmentRepository,
        appointmentRouteRepository: AppointmentRouteRepository,
        authRepository: AuthRepository
    ) {
        self.appointmentRepository = appointmentRepository
        self.appointmentRouteRepository = appointmentRouteRepository
        self.authRepository = authRepository
    }

    func execute(
        appointmentID: String
    ) async throws -> (appointment: Appointment, routes: [String: Route], currentUserID: String) {
        guard let currentUserID = authRepository.currentUserID else {
            throw AppError.notAuthenticated
        }

        async let appointment = appointmentRepository.fetchAppointment(appointmentID: appointmentID)
        async let routes = appointmentRouteRepository.fetchRoutes(appointmentID: appointmentID)
        return try await (appointment, routes, currentUserID)
    }

}
