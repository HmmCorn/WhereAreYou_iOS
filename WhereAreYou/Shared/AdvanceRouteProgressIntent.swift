//
//  AdvanceRouteProgressIntent.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-26.
//

import Foundation
import AppIntents

/// 라이브 액티비티의 단계 버튼("출발했나요?" 등) — 누르면 액티비티를 다음 확인 지점으로 넘긴다.
/// LiveActivityIntent라 앱 프로세스에서 실행된다. 처리는 앱이 AppDependencyManager에 등록한 RouteProgressService에 맡긴다
struct AdvanceRouteProgressIntent: LiveActivityIntent {

    static var title: LocalizedStringResource = "이동 단계 진행"
    static var isDiscoverable = false

    @Parameter(title: "약속 ID")
    var appointmentID: String

    @AppDependency
    private var routeProgressService: RouteProgressService

    init() { }

    init(appointmentID: String) {
        self.appointmentID = appointmentID
    }

    func perform() async throws -> some IntentResult {
        await routeProgressService.advance(appointmentID: appointmentID)
        return .result()
    }

}
