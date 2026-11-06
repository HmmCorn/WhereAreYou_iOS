//
//  AppointmentRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-06.
//

import Foundation

/// 약속 문서 저장소 — 생성·참여·나가기(서버 처리)와 조회·정보 수정. 참여자별 경로는 AppointmentRouteRepository가 맡는다
protocol AppointmentRepository {

    func createAppointment(name: String, dateTime: Date, place: Place?) async throws -> Appointment

    /// 코드에 해당하는 약속이 없으면 AppError.notFound
    func joinAppointment(code: String) async throws -> Appointment

    /// 마지막 참여자가 나가면 약속이 삭제된다. 이미 없거나 참여하지 않은 약속이어도 성공한다
    func leaveAppointment(appointmentID: String) async throws

    func fetchAppointment(appointmentID: String) async throws -> Appointment

    /// 내가 참여 중인 약속을 약속 시각 오름차순으로 돌려준다. from 이상 to 미만이며, to가 nil이면 끝을 제한하지 않는다
    func fetchMyAppointments(from: Date, to: Date?) async throws -> [Appointment]

    /// nil인 항목은 변경하지 않는다
    func updateAppointment(
        appointmentID: String,
        name: String?,
        dateTime: Date?,
        place: Place?
    ) async throws -> Appointment

}
