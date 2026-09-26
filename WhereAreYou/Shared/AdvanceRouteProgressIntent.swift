//
//  AdvanceRouteProgressIntent.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-26.
//

import Foundation
import AppIntents

/// 라이브 액티비티의 단계 버튼("출발했나요?" 등) — 누르면 액티비티를 다음 확인 지점으로 넘긴다.
/// LiveActivityIntent는 앱 프로세스에서 실행되므로 실제 처리는 앱 타깃에서만 컴파일된다
struct AdvanceRouteProgressIntent: LiveActivityIntent {

    static var title: LocalizedStringResource = "이동 단계 진행"
    static var isDiscoverable = false

    @Parameter(title: "약속 ID")
    var appointmentID: String

    init() { }

    init(appointmentID: String) {
        self.appointmentID = appointmentID
    }

    func perform() async throws -> some IntentResult {
        #if !WIDGET_EXTENSION
        let service = await DIContainer.shared.resolve(RouteProgressService.self)
        await service.advance(appointmentID: appointmentID)
        #endif
        return .result()
    }

}
