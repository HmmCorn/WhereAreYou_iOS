//
//  LocationPermissionState.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/25/26.
//

import CoreLocation

// MARK: - 위치 권한 화면에서 사용하는 표시 전용 모델
//       - CoreLocation의 CLAuthorizationStatus와 1:1 대응하되,
//         Presentation 레이어가 CoreLocation 프레임워크 타입을 직접 다루지 않도록 분리

enum LocationPermissionState {

    case notDetermined
    case denied
    case restricted
    case authorizedAlways
    case authorizedWhenInUse

    init(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined: self = .notDetermined
        case .denied: self = .denied
        case .restricted: self = .restricted
        case .authorizedAlways: self = .authorizedAlways
        case .authorizedWhenInUse: self = .authorizedWhenInUse
        @unknown default: self = .notDetermined
        }
    }

}
