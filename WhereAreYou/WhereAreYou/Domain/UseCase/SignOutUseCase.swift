//
//  SignOutUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-03.
//

import Foundation

/// 로그아웃 — FCM 설치 ID 삭제 후 Firebase Auth 세션 해제
final class SignOutUseCase {

    private let authRepository: AuthRepository
    private let fcmInstallationIDRepository: FCMInstallationIDRepository

    init(authRepository: AuthRepository, fcmInstallationIDRepository: FCMInstallationIDRepository) {
        self.authRepository = authRepository
        self.fcmInstallationIDRepository = fcmInstallationIDRepository
    }

    func execute() async throws {
        if let userID = authRepository.currentUserID {
            try? await fcmInstallationIDRepository.delete(forUserID: userID)
        }
        try authRepository.signOut()
    }

}
