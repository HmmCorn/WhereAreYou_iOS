//
//  LiveActivityPermissionStatus.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-26.
//

/// 실시간 현황(라이브 액티비티) 허용 상태. 위치 권한과 달리 앱에서 요청할 수 없고 설정 앱에서만 바꿀 수 있다
enum LiveActivityPermissionStatus {

    /// 설정 앱에서 실시간 현황이 켜진 상태 (기본값)
    case allowed
    /// 사용자가 설정 앱이나 잠금화면에서 실시간 현황을 끈 상태
    case denied

}
