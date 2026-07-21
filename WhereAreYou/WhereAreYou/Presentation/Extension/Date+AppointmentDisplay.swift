//
//  Date+AppointmentDisplay.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/21/26.
//

import Foundation

// MARK: - 약속 날짜/시간을 화면에 표시할 문자열로 변환
//       - 올해면 연도를 생략하고, 올해가 아니면 연도를 포함해 표시

extension Date {

    var appointmentDateTimeText: String {
        isThisYear ? monthDayTimeString : koreanDateTimeString
    }

    private var isThisYear: Bool {
        Calendar.current.component(.year, from: self) == Calendar.current.component(.year, from: Date())
    }

}
