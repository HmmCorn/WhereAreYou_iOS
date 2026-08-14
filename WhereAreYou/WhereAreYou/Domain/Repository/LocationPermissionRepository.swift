//
//  LocationPermissionRepository.swift
//  WhereAreYou
//
//  Created by 김성훈 on 8/14/26.
//

import Combine

/// 위치 권한 상태의 조회 및 구독을 담당
protocol LocationPermissionRepository {

    /// 현재 위치 권한 상태
    var authorizationStatus: LocationPermissionStatus { get }
    /// 위치 권한 상태가 변경될 때마다 발행되는 스트림
    var authorizationStatusPublisher: AnyPublisher<LocationPermissionStatus, Never> { get }
    /// 위치 권한을 요청
    func requestAuthorization()

}
