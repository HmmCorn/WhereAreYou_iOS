//
//  LoginViewModel.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-03.
//

import Foundation
import Combine

/// 로그인 화면의 데이터 — UI 상태 관리 및 UseCase 위임
@MainActor
final class LoginViewModel {

    @Published private(set) var loginResult: Result<User, AppError>?

    private let signInUseCase: SignInUseCase

    init(signInUseCase: SignInUseCase) {
        self.signInUseCase = signInUseCase
    }

    // MARK: - 로그인

    func signIn() {
        Task {
            do {
                let user = try await signInUseCase.execute()
                loginResult = .success(user)
            } catch is SignInError {
                return
            } catch let error as AppError {
                loginResult = .failure(error)
            } catch {
                loginResult = .failure(.unknown(error))
            }
        }
    }

}
