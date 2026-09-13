//
//  SignOutUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-03.
//

import Foundation

/// 로그아웃 — Firebase Auth 세션 해제
final class SignOutUseCase {

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute() throws {
        try authRepository.signOut()
    }

}
