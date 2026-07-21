//
//  Date+RemainingTime.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/19/26.
//

import Foundation

// MARK: - 현재 시각 기준 남은 시간을 화면에 표시할 문자열로 변환
//       - 약속 시간이 지났다면 nil을 반환해 "남은 시간 표시 안 함" 규칙을 표현
//       - 경계 판정과 단위 숫자 계산 모두 시간(hour) 차이 하나만 기준으로 함 (달력 월/년 컴포넌트 미사용)
//         - 12시간 이하 → 시간 단위
//         - 30일(24*30시간) 이하 → 일 단위
//         - 365일(24*365시간) 이하 → 개월 단위 (30일 = 1개월로 근사)
//         - 그 외 → 연 단위 (365일 = 1년으로 근사)

extension Date {

    var remainingTimeText: String? {
        let hours = Calendar.current.dateComponents([.hour], from: Date(), to: self).hour ?? 0

        guard hours >= 0 else { return nil }

        if hours <= 12 {
            return "\(hours)시간 남음"
        }
        if hours <= 24 * 30 {
            return "\(hours / 24)일 남음"
        }
        if hours <= 24 * 365 {
            return "\(hours / 24 / 30)개월 남음"
        }
        return "\(hours / 24 / 365)년 남음"
    }

}
