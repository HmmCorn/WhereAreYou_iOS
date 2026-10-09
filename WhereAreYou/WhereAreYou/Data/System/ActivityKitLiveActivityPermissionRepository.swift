//
//  ActivityKitLiveActivityPermissionRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-26.
//

import ActivityKit
import Combine

/// ActivityAuthorizationInfo로 실시간 현황 허용 상태를 읽고, 설정 앱에서 바뀌면 발행한다
final class ActivityKitLiveActivityPermissionRepository: LiveActivityPermissionRepository {

    private let authorizationInfo = ActivityAuthorizationInfo()
    private let authorizationStatusSubject: CurrentValueSubject<LiveActivityPermissionStatus, Never>
    private var enablementObservationTask: Task<Void, Never>?

    init() {
        authorizationStatusSubject = CurrentValueSubject(
            LiveActivityPermissionStatus(isEnabled: authorizationInfo.areActivitiesEnabled)
        )
        enablementObservationTask = Task { [weak self, authorizationInfo] in
            for await isEnabled in authorizationInfo.activityEnablementUpdates {
                self?.authorizationStatusSubject.send(LiveActivityPermissionStatus(isEnabled: isEnabled))
            }
        }
    }

    deinit {
        enablementObservationTask?.cancel()
    }

    var authorizationStatus: LiveActivityPermissionStatus {
        LiveActivityPermissionStatus(isEnabled: authorizationInfo.areActivitiesEnabled)
    }

    var authorizationStatusPublisher: AnyPublisher<LiveActivityPermissionStatus, Never> {
        authorizationStatusSubject.eraseToAnyPublisher()
    }

}

private extension LiveActivityPermissionStatus {

    init(isEnabled: Bool) {
        self = isEnabled ? .allowed : .denied
    }

}
