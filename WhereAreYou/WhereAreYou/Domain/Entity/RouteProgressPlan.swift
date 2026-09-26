//
//  RouteProgressPlan.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-26.
//

import Foundation

/// 약속 이동 한 번의 고정 정보 — 약속 요약, 구간 목록, 확인 지점 목록. 이동 중에는 바뀌지 않는다
struct RouteProgressPlan {

    let appointmentID: String
    let appointmentName: String
    let placeName: String
    let appointmentTime: Date
    let participantCount: Int
    let segments: [RouteProgressSegment]
    let checkpoints: [RouteCheckpoint]

}
