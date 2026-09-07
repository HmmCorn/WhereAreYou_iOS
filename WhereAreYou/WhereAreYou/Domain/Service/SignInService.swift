//
//  SignInService.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-06.
//

import Foundation

/// 로그인 서비스 — 인증 제공자에 독립적인 로그인 추상화
protocol SignInService {

    func signIn() async throws -> SignInCredential

}
