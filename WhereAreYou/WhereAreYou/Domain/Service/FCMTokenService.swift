//
//  FCMTokenService.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-20.
//

import Foundation

/// FCM 토큰 서비스 — 현재 로그인된 유저의 FCM 디바이스 토큰 저장·삭제
final class FCMTokenService {

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
