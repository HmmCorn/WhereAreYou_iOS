//
//  LocationPermissionState.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/25/26.
//

/// 위치 권한 화면에서 사용하는 표시 전용 모델
enum LocationPermissionState: Equatable {

    case notDetermined
    case denied
    case restricted
    case authorizedAlways
    case authorizedWhenInUse

    nonisolated init(_ status: LocationPermissionStatus) {
        switch status {
        case .notDetermined: self = .notDetermined
        case .denied: self = .denied
        case .restricted: self = .restricted
        case .authorizedAlways: self = .authorizedAlways
        case .authorizedWhenInUse: self = .authorizedWhenInUse
        }
    }

}
