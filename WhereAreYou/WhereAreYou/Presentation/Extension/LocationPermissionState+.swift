//
//  LocationPermissionState+.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/25/26.
//

extension LocationPermissionState {

    var title: String {
        switch self {
        case .notDetermined: return "권한 설정이 필요해요"
        case .denied: return "위치 권한이 거부되었어요"
        case .restricted: return "위치 권한이 제한되었어요"
        case .authorizedAlways: return "항상 허용"
        case .authorizedWhenInUse: return "앱 사용 중에만 허용"
        }
    }

}
