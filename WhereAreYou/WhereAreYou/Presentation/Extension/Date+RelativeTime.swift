//
//  Date+RelativeTime.swift
//  WhereAreYou
//
//  Created by 김성훈 on 8/5/26.
//

import Foundation

extension Date {

    /// 현재 시각 기준 이 시각까지 남은 시간 텍스트, 이미 지난 시각이면 "0분"
    var minutesRemainingText: String {
        let minutes = max(0, Int(timeIntervalSinceNow / 60))
        return "\(minutes)분"
    }

    /// 이 시각으로부터 현재까지 경과한 시간 텍스트, 아직 도래하지 않았으면 "0분 전"
    var elapsedMinutesText: String {
        let minutes = max(0, Int(-timeIntervalSinceNow / 60))
        return "\(minutes)분 전"
    }

}
