//
//  AppointmentListItem.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/21/26.
//

import Foundation

// MARK: - 약속 목록 / 지난 약속 화면의 카드 하나에 대응하는 표시 전용 모델

struct AppointmentListItem {
    let id: String
    let title: String
    let participantCount: Int
    let location: AppointmentLocation?
    let date: Date?
    let isNotificationEnabled: Bool
}
