//
//  FetchMyUserUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-11-15.
//

import Foundation

/// 로그인한 내 유저 정보를 조회한다 — 로그인 상태가 아니면 AppError.notAuthenticated
final class FetchMyUserUseCase {

    private let authRepository: AuthRepository
    private let userRepository: UserRepository

    init(authRepository: AuthRepository, userRepository: UserRepository) {
        self.authRepository = authRepository
        self.userRepository = userRepository
    }

    func execute() async throws -> User {
        guard let userID = authRepository.currentUserID else {
            throw AppError.notAuthenticated
        }
        return try await userRepository.fetchUser(userID: userID)
    }

}
