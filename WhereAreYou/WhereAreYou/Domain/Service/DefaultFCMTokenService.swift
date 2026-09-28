//
//  DefaultFCMTokenService.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-28.
//

import Foundation

/// FCMTokenService 구현 — 인증 저장소에서 현재 유저 ID를 얻어 FCM 토큰 저장소에 저장·삭제한다
final class DefaultFCMTokenService: FCMTokenService {

    private let authRepository: AuthRepository
    private let fcmTokenRepository: FCMTokenRepository

    init(authRepository: AuthRepository, fcmTokenRepository: FCMTokenRepository) {
        self.authRepository = authRepository
        self.fcmTokenRepository = fcmTokenRepository
    }

    func save(token: String) async throws {
        guard let userID = authRepository.currentUserID else { return }
        try await fcmTokenRepository.save(token: token, forUserID: userID)
    }

    func deleteForCurrentUser() async throws {
        guard let userID = authRepository.currentUserID else { return }
        try await fcmTokenRepository.delete(forUserID: userID)
    }

}
