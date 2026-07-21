//
//  Date+RemainingTime.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/19/26.
//

import Foundation

// MARK: - 현재 시각 기준 남은 시간을 화면에 표시할 문자열로 변환
//       - 약속 시간이 지났다면(self < 지금) nil을 반환해 "남은 시간 표시 안 함" 규칙을 표현
//         지남 여부는 Date 값 자체(초 단위)로 판정 — hour 절삭값으로 판정하면 자정 근처 등에서 오판 가능
//       - 안 지났다면 시간(hour) 차이를 기준으로 구간을 나눠 단위를 정함 (달력 월/년 컴포넌트 미사용)
//       - 각 구간의 경계는 그 구간에서 쓰는 나눗셈 단위와 맞춰, 정수 나눗셈으로 값이 0이 되는 경우가 없도록 함
//         - 1시간 미만 → "곧 시작"
//         - 24시간 미만 → 시간 단위
//         - 30일(24*30시간) 미만 → 일 단위
//         - 365일(24*365시간) 미만 → 개월 단위 (30일 = 1개월로 근사)
//         - 그 외 → 연 단위 (365일 = 1년으로 근사)

extension Date {

    var remainingTimeText: String? {
        guard self >= Date() else { return nil }

        let hours = Calendar.current.dateComponents([.hour], from: Date(), to: self).hour ?? 0

        if hours == 0 {
            return "곧 시작"
        }
        if hours < 24 {
            return "\(hours)시간 남음"
        }
        if hours < 24 * 30 {
            return "\(hours / 24)일 남음"
        }
        if hours < 24 * 365 {
            return "\(hours / 24 / 30)개월 남음"
        }
        return "\(hours / 24 / 365)년 남음"
    }

}
