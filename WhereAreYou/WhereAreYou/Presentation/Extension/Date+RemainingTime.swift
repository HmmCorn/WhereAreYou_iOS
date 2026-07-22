//
//  Date+RemainingTime.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/19/26.
//

import Foundation

// MARK: - 현재 시각 기준 남은 시간을 화면에 표시할 문자열로 변환
//       - 순수 포맷 변환이 아니라 "지금"을 참조하는 프레젠테이션 로직이라 Core가 아닌 Presentation에 위치

extension Date {

    var remainingTimeText: String {
        let hours = Calendar.current.dateComponents([.hour], from: Date(), to: self).hour ?? 0

        if hours >= 24 {
            return "\(hours / 24)일 남음"
        }
        return "\(hours)시간 남음"
    }

}
