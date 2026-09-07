//
//  AuthRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-03.
//

import Foundation

/// 인증 저장소 — Apple 로그인, 로그아웃, 현재 로그인 상태 확인
protocol AuthRepository {

    var currentUserID: String? { get }

    func signIn(idToken: String, nonce: String) async throws -> String

    func signOut() throws

}
