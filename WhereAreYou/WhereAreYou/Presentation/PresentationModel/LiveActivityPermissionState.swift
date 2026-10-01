//
//  LiveActivityPermissionState.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-26.
//

/// 마이페이지 실시간 현황 설정 행에서 사용하는 표시 전용 모델
enum LiveActivityPermissionState: Equatable {

    case allowed
    case denied

    nonisolated init(_ status: LiveActivityPermissionStatus) {
        switch status {
        case .allowed: self = .allowed
        case .denied: self = .denied
        }
    }

}
