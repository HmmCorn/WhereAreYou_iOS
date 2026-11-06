//
//  LeaveAppointmentUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-10-29.
//

/// 약속 나가기 — 마지막 참여자면 서버가 약속을 삭제한다
final class LeaveAppointmentUseCase {

    private let repository: AppointmentRepository

    init(repository: AppointmentRepository) {
        self.repository = repository
    }

    func execute(appointmentID: String) async throws {
        try await repository.leaveAppointment(appointmentID: appointmentID)
    }

}
