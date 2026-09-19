//
//  SessionValidationService.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-20.
//

import Foundation

/// 세션 검증 결과
enum SessionValidationResult {
    case valid
    case networkError
    case invalid
}

/// 세션 검증 서비스 — 현재 로그인된 유저가 유효한지 확인
final class SessionValidationService {

    private let authRepository: AuthRepository
    private let userRepository: UserRepository

    init(authRepository: AuthRepository, userRepository: UserRepository) {
        self.authRepository = authRepository
        self.userRepository = userRepository
    }

    var currentUserID: String? {
        authRepository.currentUserID
    }

    func validate() async -> SessionValidationResult {
        guard let userID = authRepository.currentUserID else { return .invalid }
        do {
            _ = try await userRepository.fetchUser(userID: userID)
            return .valid
        } catch AppError.network {
            return .networkError
        } catch {
            return .invalid
        }
    }

}
