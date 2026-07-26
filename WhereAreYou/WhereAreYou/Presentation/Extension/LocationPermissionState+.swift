//
//  LocationPermissionState+.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/25/26.
//

extension LocationPermissionState {

    var title: String {
        switch self {
        case .notDetermined: return "권한 설정 필요"
        case .denied: return "위치 권한 거부"
        case .restricted: return "위치 권한 제한"
        case .authorizedAlways: return "항상 허용"
        case .authorizedWhenInUse: return "앱 사용 중에만 허용"
        }
    }

    var description: String {
        switch self {
        case .notDetermined: return "설정에서 위치 권한을 허용하면\n약속 상대방과 위치를 공유할 수 있어요"
        case .denied: return "설정 앱에서 위치 권한을 허용해주세요"
        case .restricted: return "기기 설정으로 인해 위치 권한을 사용할 수 없어요"
        case .authorizedAlways: return "위치 권한이 정상적으로 허용되어 있어요"
        case .authorizedWhenInUse: return "위치 권한이 정상적으로 허용되어 있어요"
        }
    }

    var iconName: String {
        switch self {
        case .notDetermined: return "location.circle"
        case .denied, .restricted: return "location.slash"
        case .authorizedAlways, .authorizedWhenInUse: return "location.fill"
        }
    }

    var isGranted: Bool {
        switch self {
        case .authorizedAlways, .authorizedWhenInUse: return true
        case .notDetermined, .denied, .restricted: return false
        }
    }

}
