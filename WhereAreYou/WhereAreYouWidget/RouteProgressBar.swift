//
//  RouteProgressBar.swift
//  WhereAreYouWidget
//
//  Created by 이상유 on 2026-09-26.
//

import SwiftUI

/// 경로 진행 바 — 구간마다 도보·자동차 아이콘 또는 노선 색 칩을 잇고, 지나온 구간과 남은 구간을 흐리기로 구분한다
struct RouteProgressBar: View {

    let segments: [AppointmentRouteActivityAttributes.Segment]
    /// 출발 전이면 nil, 도착했으면 segments.count
    let currentIndex: Int?

    var body: some View {
        HStack(spacing: 4) {
            ForEach(segments.indices, id: \.self) { index in
                let segment = segments[index]
                if index > 0 {
                    Capsule()
                        .fill(isPassed(index) || isCurrent(index) ? WidgetPalette.accent : Color.secondary.opacity(0.3))
                        .frame(height: 2)
                        .frame(minWidth: 6)
                }
                RouteSegmentChip(segment: segment)
                    .opacity(isPassed(index) ? 0.45 : (isCurrent(index) || currentIndex == nil ? 1 : 0.7))
                    .overlay {
                        if isCurrent(index) {
                            Capsule().stroke(WidgetPalette.accent, lineWidth: 2).padding(-2)
                        }
                    }
            }
        }
    }

    private func isPassed(_ index: Int) -> Bool {
        guard let currentIndex else { return false }
        return index < currentIndex
    }

    private func isCurrent(_ index: Int) -> Bool {
        index == currentIndex
    }

}

/// 구간 칩 하나 — 대중교통은 노선 색 캡슐에 노선명(버스는 아이콘 + 번호), 도보·자동차는 아이콘
struct RouteSegmentChip: View {

    let segment: AppointmentRouteActivityAttributes.Segment

    var body: some View {
        Group {
            if let lineName = segment.lineName {
                // "4호선"은 이름만으로 지하철인 걸 알 수 있지만 버스 번호는 숫자뿐이라 아이콘을 붙인다
                HStack(spacing: 2) {
                    if segment.transport == .bus {
                        Image(systemName: segment.symbolName)
                    }
                    Text(lineName)
                        .lineLimit(1)
                        .fixedSize()
                }
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white)
            } else {
                Image(systemName: segment.symbolName)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(Capsule().fill(segment.tint))
    }

}

extension AppointmentRouteActivityAttributes.Segment {

    var symbolName: String {
        switch transport {
        case .walk: return "figure.walk"
        case .car: return "car.fill"
        case .subway: return "tram.fill"
        case .bus: return "bus.fill"
        }
    }

    var tint: Color {
        switch transport {
        case .walk: return WidgetPalette.walk
        case .car: return WidgetPalette.car
        case .subway, .bus: return lineColorHex.flatMap(Color.init(hex:)) ?? WidgetPalette.transitFallback
        }
    }

}
