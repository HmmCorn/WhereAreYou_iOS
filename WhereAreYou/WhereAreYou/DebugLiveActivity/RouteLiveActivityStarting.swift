//
//  RouteLiveActivityStarting.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-27.
//

#if DEBUG
import Foundation

/// [임시 · 3단계에서 삭제] 앱에서 약속 이동 라이브 액티비티를 직접 시작한다.
/// 3단계에서는 서버 push-to-start가 시작을 맡으므로, 정식 저장소(RouteLiveActivityRepository)와 분리해 이 폴더째 지울 수 있게 했다
protocol RouteLiveActivityStarting {

    /// 떠 있는 약속 이동 액티비티를 모두 종료하고 새로 시작한다
    func start(plan: RouteProgressPlan, status: RouteProgressStatus) async throws

}
#endif
