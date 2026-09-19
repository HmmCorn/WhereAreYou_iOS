//
//  SignOutUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-03.
//

import Foundation

/// 로그아웃 — FCM 토큰 삭제 후 Firebase Auth 세션 해제
final class SignOutUseCase {

    private let authRepository: AuthRepository
    private let fcmTokenRepository: FCMTokenRepository

    init(authRepository: AuthRepository, fcmTokenRepository: FCMTokenRepository) {
        self.authRepository = authRepository
        self.fcmTokenRepository = fcmTokenRepository
    }

    func execute() async throws {
        if let userID = authRepository.currentUserID {
            try? await fcmTokenRepository.delete(forUserID: userID)
        }
        try authRepository.signOut()
    }

}
