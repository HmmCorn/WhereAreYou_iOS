//
//  RouteCheckpoint.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-26.
//

import Foundation

/// 이동 중 "~했나요?"로 확인받는 지점 하나 — 종류, 장소, 예정 시각, 도달 후 진행 중인 구간
struct RouteCheckpoint {

    /// 탑승 수단 기준 확인 지점 종류
    enum Kind {
        /// 출발했나요?
        case departure
        /// 첫 탑승역에 도착했나요?
        case boarding
        /// 하차역에 도착했나요? (환승역 포함)
        case alighting
        /// 약속 장소에 도착했나요?
        case arrival
    }

    let kind: Kind
    let placeName: String
    let scheduledTime: Date
    /// 이 지점에 도달한 뒤 사용자가 이동 중인 구간 인덱스. 도착이면 구간 수와 같다
    let segmentIndex: Int

}
