//
//  WidgetPalette.swift
//  WhereAreYouWidget
//
//  Created by 이상유 on 2026-09-26.
//

import SwiftUI

/// 위젯 익스텐션 색상 — 앱 에셋 카탈로그를 쓸 수 없어 필요한 색만 옮겨 둔다
enum WidgetPalette {

    /// 앱 pointBlue
    static let accent = Color(hex: "#4E7AC7") ?? .blue
    /// 약속 시간이 지난 뒤의 경과 시간 — 앱 customRed
    static let overdue = Color(hex: "#C94F5C") ?? .red
    /// 도보 구간 — 초록 노선(2호선 등)과 헷갈리지 않도록 무채색
    static let walk = Color.gray
    /// 자동차 구간 — 앱의 TransportType.car 색과 같다
    static let car = Color.indigo
    /// 노선 색 정보가 없는 대중교통 구간 — 앱의 TransportType.transit 색과 같다
    static let transitFallback = Color.yellow

}

extension Color {

    /// "#RRGGBB" 형식만 받는다. 형식이 다르면 nil
    nonisolated init?(hex: String) {
        let value = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        guard value.count == 6, let rgb = UInt32(value, radix: 16) else { return nil }
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }

}
