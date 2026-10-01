//
//  LiveActivityPermissionRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-26.
//

import Combine

/// 실시간 현황 허용 상태의 조회 및 구독을 담당
protocol LiveActivityPermissionRepository {

    /// 현재 실시간 현황 허용 상태
    var authorizationStatus: LiveActivityPermissionStatus { get }
    /// 허용 상태가 바뀔 때마다 발행되는 스트림
    var authorizationStatusPublisher: AnyPublisher<LiveActivityPermissionStatus, Never> { get }

}
