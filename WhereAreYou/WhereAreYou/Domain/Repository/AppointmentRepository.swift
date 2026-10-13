//
//  AppointmentRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-06.
//

import Foundation

/// 약속 문서 저장소 — 생성·참여(서버 처리)와 조회·정보 수정. 참여자별 경로는 AppointmentRouteRepository가 맡는다
protocol AppointmentRepository {

    func createAppointment(name: String, dateTime: Date, place: Place?) async throws -> Appointment

    /// 코드에 해당하는 약속이 없으면 AppError.notFound
    func joinAppointment(code: String) async throws -> Appointment

    func fetchAppointment(appointmentID: String) async throws -> Appointment

    /// nil인 항목은 변경하지 않는다
    func updateAppointment(
        appointmentID: String,
        name: String?,
        dateTime: Date?,
        place: Place?
    ) async throws -> Appointment

}
