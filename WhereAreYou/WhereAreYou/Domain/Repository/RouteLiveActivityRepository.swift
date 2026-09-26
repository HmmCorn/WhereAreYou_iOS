//
//  RouteLiveActivityRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-26.
//

import Foundation

/// 진행 중인 약속 이동 라이브 액티비티 조회·갱신·종료. 한 번에 한 약속으로만 이동하므로 액티비티는 하나만 둔다.
/// 시작은 3단계에서 서버 push-to-start가 맡는다 — 임시 시작은 DebugLiveActivity의 RouteLiveActivityStarting
protocol RouteLiveActivityRepository {

    func current(appointmentID: String) -> (plan: RouteProgressPlan, status: RouteProgressStatus)?

    func update(appointmentID: String, status: RouteProgressStatus) async

    /// 최종 상태를 반영한 뒤 dismissalDate에 화면에서 내린다
    func end(appointmentID: String, status: RouteProgressStatus, dismissalDate: Date) async

}
