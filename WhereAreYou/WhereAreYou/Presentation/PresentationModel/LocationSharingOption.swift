//
//  LocationSharingOption.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/24/26.
//

// MARK: - 위치 공유 설정 화면에서 사용하는 표시 전용 모델
//       - Domain의 LocationSharingScope와 1:1 대응하되,
//         Presentation 레이어가 Domain 엔티티를 직접 참조하지 않도록 분리

enum LocationSharingOption: CaseIterable {

    case always
    case onlyDuringAppointment
    case never

}
