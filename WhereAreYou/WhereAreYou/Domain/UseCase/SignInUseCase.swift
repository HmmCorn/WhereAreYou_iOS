//
//  SignInUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-06.
//

import Foundation

/// 로그인 유스케이스 — 인증 → 유저 문서 생성 흐름을 조합
final class SignInUseCase {

    private let signInService: SignInService
    private let authRepository: AuthRepository
    private let userRepository: UserRepository

    init(
        signInService: SignInService,
        authRepository: AuthRepository,
        userRepository: UserRepository
    ) {
        self.signInService = signInService
        self.authRepository = authRepository
        self.userRepository = userRepository
    }

    func execute() async throws -> User {
        let credential = try await signInService.signIn()
        let userID = try await authRepository.signIn(
            idToken: credential.idToken,
            nonce: credential.nonce
        )
        return try await userRepository.createUserIfNeeded(
            userID: userID,
            nickname: credential.nickname ?? "유저"
        )
    }

}
