//
//  Date+Format.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-14.
//

import Foundation

extension Date {

    private static let koreanDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter
    }()

    var koreanDateString: String {
        Self.koreanDateFormatter.string(from: self)
    }

}
