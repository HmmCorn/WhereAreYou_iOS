//
//  DefaultSessionValidationService.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-28.
//

import Foundation

/// SessionValidationService 구현 — 인증 저장소의 현재 유저를 유저 저장소에서 다시 조회해 유효성을 판단한다
final class DefaultSessionValidationService: SessionValidationService {

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
