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

    var monthDayTimeString: String {
        Self.monthDayTimeFormatter.string(from: self)
    }

    var koreanShortDateTimeString: String {
        Self.koreanShortDateTimeFormatter.string(from: self)
    }

    var koreanTimeString: String {
        Self.koreanTimeFormatter.string(from: self)
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

    private static let monthDayTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "MM월 dd일 HH:mm"
        return formatter
    }()

    private static let koreanShortDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E) a h:mm"
        return formatter
    }()

    private static let koreanTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

}
