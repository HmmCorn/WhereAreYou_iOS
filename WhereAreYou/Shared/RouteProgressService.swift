//
//  RouteProgressService.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-28.
//

import Foundation

/// 약속 이동 진행 서비스 — 라이브 액티비티 단계 버튼(LiveActivityIntent)이 화면 없이 부른다.
/// 인텐트가 이 프로토콜만 알도록 앱·위젯 공용 폴더에 둔다. 구현(DefaultRouteProgressService)은 앱 타깃에만 있고,
/// 앱 시작 시 AppDependencyManager에 등록해 인텐트의 @AppDependency로 주입한다
protocol RouteProgressService: Sendable {

    /// 다음 확인 지점으로 넘긴다. 마지막 지점이면 액티비티를 종료한다
    func advance(appointmentID: String) async

}
