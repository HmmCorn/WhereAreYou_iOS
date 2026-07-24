//
//  LocationPermissionState.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/25/26.
//

// MARK: - 위치 권한 화면에서 사용하는 표시 전용 모델

enum LocationPermissionState {

    case notDetermined
    case denied
    case restricted
    case authorizedAlways
    case authorizedWhenInUse

}
