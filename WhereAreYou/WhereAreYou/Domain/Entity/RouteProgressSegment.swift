//
//  RouteProgressSegment.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-26.
//

/// 진행 바의 구간 하나 — RouteStep에서 좌표·Place를 뺀 표시용 요약. 라이브 액티비티 용량 제한 때문에 따로 둔다
struct RouteProgressSegment {

    /// 대중교통 구간의 탈것 — 아이콘 구분용
    enum TransitVehicle {
        case subway
        case bus
    }

    let transportType: TransportType
    /// 대중교통이 아니면 nil
    let transitVehicle: TransitVehicle?
    let destinationName: String
    let estimatedMinutes: Int
    let lineName: String?
    let lineColorHex: String?
    let stopCount: Int?

}

extension RouteProgressSegment {

    /// 탑승 장소가 지하철역이면 지하철, 아니면 버스로 본다
    init(step: RouteStep) {
        self.init(
            transportType: step.transportType,
            transitVehicle: step.transportType == .transit
                ? (step.departurePoint.type == .subway ? .subway : .bus)
                : nil,
            destinationName: step.destination.name,
            estimatedMinutes: Int(step.estimatedTime.rounded()),
            lineName: step.lineName,
            lineColorHex: step.lineColorHex,
            stopCount: step.stopCount
        )
    }

}
