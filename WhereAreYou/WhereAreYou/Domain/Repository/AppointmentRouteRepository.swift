//
//  AppointmentRouteRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-10-12.
//

import Foundation

/// 약속 참여자별 경로 저장소 — 약속 문서와 따로 저장되는 routes 하위 컬렉션을 다룬다
protocol AppointmentRouteRepository {

    /// 참여자 ID → 경로. 경로를 아직 정하지 않은 참여자는 빠진다
    func fetchRoutes(appointmentID: String) async throws -> [String: Route]

}
