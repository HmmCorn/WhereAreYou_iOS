//
//  Date+Format.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-14.
//

import Foundation

extension Date {

    var koreanDateString: String {
        Self.koreanDateFormatter.string(from: self)
    }

    var koreanDateTimeString: String {
        Self.koreanDateTimeFormatter.string(from: self)
    }

    var remainingTimeText: String {
        let hours = Calendar.current.dateComponents([.hour], from: Date(), to: self).hour ?? 0

        if hours >= 24 {
            return "\(hours / 24)일 남음"
        }
        return "\(hours)시간 남음"
    }

    private static let koreanDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter
    }()

    private static let koreanDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월 dd일 HH:mm"
        return formatter
    }()

}
