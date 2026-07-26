//
//  MyPageProfile.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/24/26.
//

// MARK: - 마이페이지 화면에 표시되는 사용자 정보의 표시 전용 모델

struct MyPageProfile {
    let nickname: String
    let profileImageName: String
    let locationSharingOption: LocationSharingOption
    let isNotificationEnabled: Bool
}
