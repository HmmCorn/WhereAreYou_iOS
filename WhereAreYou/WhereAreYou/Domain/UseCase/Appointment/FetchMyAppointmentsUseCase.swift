//
//  FetchMyAppointmentsUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-11-07.
//

import Foundation

/// 내가 참여 중인 약속을 기간으로 조회한다 — 홈·약속 목록·지난 약속·마이페이지가 함께 쓴다
final class FetchMyAppointmentsUseCase {

    private let repository: AppointmentRepository

    init(repository: AppointmentRepository) {
        self.repository = repository
    }

    func execute(from: Date, to: Date?) async throws -> [Appointment] {
        try await repository.fetchMyAppointments(from: from, to: to)
    }

}
