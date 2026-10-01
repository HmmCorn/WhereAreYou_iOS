//
//  AppointmentRouteActivityAttributes.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-26.
//

import Foundation
import ActivityKit

/// 약속 이동 라이브 액티비티 데이터 — 앱과 위젯 익스텐션이 함께 쓰는 전송용 모델.
/// 속성과 상태를 합쳐 4KB를 넘을 수 없으므로 좌표·Place 없이 표시에 필요한 값만 담는다
struct AppointmentRouteActivityAttributes: ActivityAttributes {

    /// 단계 버튼을 누를 때마다 바뀌는 값
    struct ContentState: Codable, Hashable {
        var reachedCheckpointCount: Int
        var arrivedParticipantCount: Int
    }

    /// 진행 바의 구간 하나
    struct Segment: Codable, Hashable {

        /// 대중교통은 아이콘을 구분하려고 지하철·버스로 나눈다
        enum Transport: String, Codable, Hashable {
            case walk
            case car
            case subway
            case bus
        }

        let transport: Transport
        let destinationName: String
        let estimatedMinutes: Int
        let lineName: String?
        let lineColorHex: String?
        let stopCount: Int?
    }

    /// "~했나요?"로 묻는 확인 지점 하나
    struct Checkpoint: Codable, Hashable {

        enum Kind: String, Codable, Hashable {
            case departure
            case boarding
            case alighting
            case arrival
        }

        let kind: Kind
        let placeName: String
        let scheduledTime: Date
        /// 이 지점에 도달한 뒤 이동 중인 구간 인덱스. 도착이면 구간 수와 같다
        let segmentIndex: Int
    }

    let appointmentID: String
    let appointmentName: String
    let placeName: String
    let appointmentTime: Date
    let participantCount: Int
    let segments: [Segment]
    let checkpoints: [Checkpoint]

}
