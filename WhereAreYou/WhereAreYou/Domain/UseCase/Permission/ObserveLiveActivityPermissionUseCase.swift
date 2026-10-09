//
//  ObserveLiveActivityPermissionUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-26.
//

import Combine

/// 실시간 현황 허용 상태의 조회와 구독을 담당. 요청 기능은 없다 — 설정 앱에서만 바꿀 수 있다
final class ObserveLiveActivityPermissionUseCase {

    private let repository: LiveActivityPermissionRepository

    init(repository: LiveActivityPermissionRepository) {
        self.repository = repository
    }

    /// 현재 실시간 현황 허용 상태
    var currentStatus: LiveActivityPermissionStatus {
        repository.authorizationStatus
    }

    /// 허용 상태가 바뀔 때마다 발행되는 스트림
    var statusPublisher: AnyPublisher<LiveActivityPermissionStatus, Never> {
        repository.authorizationStatusPublisher
    }

}
