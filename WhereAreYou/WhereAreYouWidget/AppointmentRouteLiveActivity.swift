//
//  AppointmentRouteLiveActivity.swift
//  WhereAreYouWidget
//
//  Created by 이상유 on 2026-09-26.
//

import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

/// 약속 이동 라이브 액티비티 — 잠금화면 배너와 다이나믹 아일랜드(확장·컴팩트·최소) 배치. 탭하면 약속 지도로 이동
struct AppointmentRouteLiveActivity: Widget {

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AppointmentRouteActivityAttributes.self) { context in
            AppointmentRouteLockScreenView(display: context.display)
                .activityBackgroundTint(Color(.systemBackground).opacity(0.85))
                .widgetURL(AppointmentDeepLink.route(appointmentID: context.attributes.appointmentID).url)
        } dynamicIsland: { context in
            let display = context.display

            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(display.attributes.appointmentName)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                        .padding(.leading, 8)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Label(display.arrivalText, systemImage: "person.2.fill")
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                        .padding(.trailing, 8)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        RouteProgressBar(segments: display.attributes.segments, currentIndex: display.currentSegmentIndex)
                        RouteStatusRow(display: display)
                        if !display.isArrived {
                            RouteActionButtons(display: display)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 4)
                }
            } compactLeading: {
                // 아이콘만 두면 왼쪽 끝에 붙으므로 오른쪽 타이머와 비슷한 폭 안에서 가운데 둔다
                CompactSegmentIcon(display: display)
                    .frame(width: 36)
            } compactTrailing: {
                RemainingTimeText(display: display)
                    .font(.caption2.weight(.semibold))
                    .frame(maxWidth: 44)
            } minimal: {
                CompactSegmentIcon(display: display)
            }
            .widgetURL(AppointmentDeepLink.route(appointmentID: context.attributes.appointmentID).url)
            .keylineTint(WidgetPalette.accent)
        }
    }

}

private extension ActivityViewContext<AppointmentRouteActivityAttributes> {

    var display: AppointmentRouteDisplay {
        AppointmentRouteDisplay(
            attributes: attributes,
            state: state,
            isPastAppointmentTime: isStale || Date() >= attributes.appointmentTime
        )
    }

}

// MARK: - 잠금화면

/// 잠금화면 배너 — 약속 요약, 남은 시간, 진행 바, 현재 구간, 버튼 2개. 도착하면 버튼 없이 "도착했어요"만 남는다
struct AppointmentRouteLockScreenView: View {

    let display: AppointmentRouteDisplay

    var body: some View {
        // 잠금화면 라이브 액티비티는 높이 160pt를 넘으면 그려지지 않는다. 줄 간격·위아래 여백을 늘릴 때 주의
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(display.attributes.appointmentName)
                    .font(.headline)
                    .lineLimit(1)
                Spacer(minLength: 8)
                Label(display.arrivalText, systemImage: "person.2.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(WidgetPalette.accent)
            }

            HStack(alignment: .firstTextBaseline) {
                Text(display.appointmentSummaryText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer(minLength: 8)
                if !display.isArrived {
                    HStack(spacing: 4) {
                        Text(display.isPastAppointmentTime ? "약속 시간" : "약속까지")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        // 타이머 Text는 남는 폭을 모두 차지하고 fixedSize도 쓸 수 없어, "mmm:ss"가 들어가는 폭으로 고정한다
                        RemainingTimeText(display: display)
                            .font(.caption.weight(.semibold))
                            .frame(width: 44, alignment: .trailing)
                    }
                }
            }

            RouteProgressBar(segments: display.attributes.segments, currentIndex: display.currentSegmentIndex)

            RouteStatusRow(display: display)

            if !display.isArrived {
                RouteActionButtons(display: display)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

}

// MARK: - 공용 구성요소

/// 현재 구간 1줄
struct RouteStatusRow: View {

    let display: AppointmentRouteDisplay

    var body: some View {
        HStack(spacing: 6) {
            if let segment = display.currentSegment {
                RouteSegmentChip(segment: segment)
            }
            Text(display.statusText)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
            Spacer(minLength: 0)
        }
    }

}

/// 위치 공유(앱을 열어 바로 전송)와 단계 진행(LiveActivityIntent) 버튼. 도착 후에는 표시하지 않는다
struct RouteActionButtons: View {

    let display: AppointmentRouteDisplay

    var body: some View {
        HStack(spacing: 8) {
            Link(destination: AppointmentDeepLink.shareLocation(appointmentID: display.attributes.appointmentID).url) {
                Label("위치 공유", systemImage: "location.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(WidgetPalette.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(WidgetPalette.accent.opacity(0.15)))
            }

            if let question = display.nextQuestionText {
                Button(intent: AdvanceRouteProgressIntent(appointmentID: display.attributes.appointmentID)) {
                    Label(question, systemImage: "checkmark")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(WidgetPalette.accent))
                }
                .buttonStyle(.plain)
            }
        }
    }

}

/// 약속 시각까지 남은 시간 — 지나기 전에는 카운트다운, 지난 뒤에는 빨간 "+경과 시간" 카운트업. 시간 단위 없이 분:초로 표시한다
struct RemainingTimeText: View {

    /// 미도착 액티비티는 약속 + 1시간에 서버 종료 푸시로 내릴 예정(3단계)이지만, 그 전까지는 계속 세도록 넉넉히 잡는다
    private static let overdueTimerRange: TimeInterval = 8 * 60 * 60

    let display: AppointmentRouteDisplay

    var body: some View {
        let appointmentTime = display.attributes.appointmentTime
        if display.isPastAppointmentTime {
            // "+"를 따로 두면 타이머가 남는 폭을 차지해 사이가 벌어지므로 한 Text로 잇는다
            (Text("+") + Text(
                timerInterval: appointmentTime...appointmentTime.addingTimeInterval(Self.overdueTimerRange),
                countsDown: false,
                showsHours: false
            ))
            .monospacedDigit()
            .multilineTextAlignment(.trailing)
            .foregroundStyle(WidgetPalette.overdue)
        } else {
            let now = Date()
            Text(timerInterval: now...max(now, appointmentTime), countsDown: true, showsHours: false)
                .monospacedDigit()
                .multilineTextAlignment(.trailing)
        }
    }

}

/// 다이나믹 아일랜드 컴팩트·최소 영역 — 지금 구간의 수단 아이콘을 노선 색으로
struct CompactSegmentIcon: View {

    let display: AppointmentRouteDisplay

    var body: some View {
        if display.isArrived {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(WidgetPalette.accent)
        } else if let segment = display.currentSegment {
            Image(systemName: segment.symbolName)
                .foregroundStyle(segment.tint)
        } else {
            Image(systemName: "figure.walk.departure")
                .foregroundStyle(WidgetPalette.accent)
        }
    }

}

// MARK: - Preview

#if DEBUG
private extension AppointmentRouteActivityAttributes {

    static var preview: AppointmentRouteActivityAttributes {
        makePreview(departure: Date().addingTimeInterval(60))
    }

    /// 약속 시각이 5분 지난 상태
    static var previewPastAppointment: AppointmentRouteActivityAttributes {
        makePreview(departure: Date().addingTimeInterval(-29 * 60))
    }

    private static func makePreview(departure: Date) -> AppointmentRouteActivityAttributes {
        AppointmentRouteActivityAttributes(
            appointmentID: "preview",
            appointmentName: "고기굽는방앗간 이수역점",
            placeName: "스타벅스 강남역점",
            appointmentTime: departure.addingTimeInterval(24 * 60),
            participantCount: 6,
            segments: [
                Segment(transport: .walk, destinationName: "이수역", estimatedMinutes: 6, lineName: nil, lineColorHex: nil, stopCount: nil),
                Segment(transport: .subway, destinationName: "사당역", estimatedMinutes: 2, lineName: "4호선", lineColorHex: "#00A5DE", stopCount: 1),
                Segment(transport: .walk, destinationName: "사당역", estimatedMinutes: 3, lineName: nil, lineColorHex: nil, stopCount: nil),
                Segment(transport: .subway, destinationName: "강남역", estimatedMinutes: 8, lineName: "2호선", lineColorHex: "#00A84D", stopCount: 4),
                Segment(transport: .walk, destinationName: "스타벅스 강남역점", estimatedMinutes: 4, lineName: nil, lineColorHex: nil, stopCount: nil),
            ],
            checkpoints: [
                Checkpoint(kind: .departure, placeName: "출발지", scheduledTime: departure, segmentIndex: 0),
                Checkpoint(kind: .boarding, placeName: "이수역", scheduledTime: departure.addingTimeInterval(6 * 60), segmentIndex: 1),
                Checkpoint(kind: .alighting, placeName: "사당역", scheduledTime: departure.addingTimeInterval(8 * 60), segmentIndex: 3),
                Checkpoint(kind: .alighting, placeName: "강남역", scheduledTime: departure.addingTimeInterval(19 * 60), segmentIndex: 4),
                Checkpoint(kind: .arrival, placeName: "스타벅스 강남역점", scheduledTime: departure.addingTimeInterval(23 * 60), segmentIndex: 5),
            ]
        )
    }

}

#Preview("잠금화면", as: .content, using: AppointmentRouteActivityAttributes.preview) {
    AppointmentRouteLiveActivity()
} contentStates: {
    AppointmentRouteActivityAttributes.ContentState(reachedCheckpointCount: 0, arrivedParticipantCount: 0)
    AppointmentRouteActivityAttributes.ContentState(reachedCheckpointCount: 3, arrivedParticipantCount: 2)
    AppointmentRouteActivityAttributes.ContentState(reachedCheckpointCount: 5, arrivedParticipantCount: 3)
}

#Preview("잠금화면 (약속 시간 지남)", as: .content, using: AppointmentRouteActivityAttributes.previewPastAppointment) {
    AppointmentRouteLiveActivity()
} contentStates: {
    AppointmentRouteActivityAttributes.ContentState(reachedCheckpointCount: 3, arrivedParticipantCount: 4)
}

#Preview("다이나믹 아일랜드 확장", as: .dynamicIsland(.expanded), using: AppointmentRouteActivityAttributes.preview) {
    AppointmentRouteLiveActivity()
} contentStates: {
    AppointmentRouteActivityAttributes.ContentState(reachedCheckpointCount: 3, arrivedParticipantCount: 2)
}

#Preview("다이나믹 아일랜드 컴팩트", as: .dynamicIsland(.compact), using: AppointmentRouteActivityAttributes.preview) {
    AppointmentRouteLiveActivity()
} contentStates: {
    AppointmentRouteActivityAttributes.ContentState(reachedCheckpointCount: 0, arrivedParticipantCount: 0)
    AppointmentRouteActivityAttributes.ContentState(reachedCheckpointCount: 3, arrivedParticipantCount: 2)
}
#endif
