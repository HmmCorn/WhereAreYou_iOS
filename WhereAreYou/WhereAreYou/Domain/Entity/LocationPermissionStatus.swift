//
//  LocationPermissionStatus.swift
//  WhereAreYou
//
//  Created by 김성훈 on 8/13/26.
//

/// 위치 권한 상태
enum LocationPermissionStatus {

    /// 사용자가 아직 위치 권한을 허용/거부하지 않은 상태 (최초 상태)
    case notDetermined
    /// 사용자가 위치 권한을 명시적으로 거부한 상태 (설정 앱에서 직접 허용 필요)
    case denied
    /// 자녀 보호 기능 등 기기 정책으로 인해 위치 권한 자체를 사용할 수 없는 상태 (앱에서 변경 불가)
    case restricted
    /// 앱을 사용하지 않을 때도 항상 위치 접근이 허용된 상태
    case authorizedAlways
    /// 앱을 사용하는 동안에만 위치 접근이 허용된 상태
    case authorizedWhenInUse

}
