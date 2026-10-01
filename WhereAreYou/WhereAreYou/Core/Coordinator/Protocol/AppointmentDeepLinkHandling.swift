//
//  AppointmentDeepLinkHandling.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-10-01.
//

import Foundation

/// 라이브 액티비티 딥링크를 "지금 보이는 자기 화면"에서 처리할 수 있는지 답하는 코디네이터.
/// 상위(TabBarCoordinator)는 화면 구조를 모른 채 묻기만 하고, 판단과 처리는 화면을 띄운 코디네이터가 맡는다
protocol AppointmentDeepLinkHandling: AnyObject {

    /// 지금 보이는 자기 화면이 딥링크의 약속이면 그 자리에서 처리하고 true를 돌려준다.
    /// 처리할 수 없으면 아무것도 하지 않고 false — 상위가 목적지를 새로 띄운다
    func handleInPlace(_ deepLink: AppointmentDeepLink) -> Bool

}
