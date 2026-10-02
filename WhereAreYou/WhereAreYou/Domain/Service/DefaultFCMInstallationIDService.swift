//
//  DefaultFCMInstallationIDService.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-28.
//

import Foundation

/// FCMInstallationIDService 구현 — 인증 저장소에서 현재 유저 ID를 얻어 FCM 설치 ID 저장소에 저장·삭제한다
final class DefaultFCMInstallationIDService: FCMInstallationIDService {

    private let authRepository: AuthRepository
    private let fcmInstallationIDRepository: FCMInstallationIDRepository

    init(authRepository: AuthRepository, fcmInstallationIDRepository: FCMInstallationIDRepository) {
        self.authRepository = authRepository
        self.fcmInstallationIDRepository = fcmInstallationIDRepository
    }

    func save(installationID: String) async throws {
        guard let userID = authRepository.currentUserID else { return }
        try await fcmInstallationIDRepository.save(installationID: installationID, forUserID: userID)
    }

    func deleteForCurrentUser() async throws {
        guard let userID = authRepository.currentUserID else { return }
        try await fcmInstallationIDRepository.delete(forUserID: userID)
    }

}
