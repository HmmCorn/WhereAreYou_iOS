//
//  UserRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-03.
//

import Foundation

/// 사용자 저장소 — Firestore 유저 문서 생성, 조회
protocol UserRepository {

    func createUserIfNeeded(userID: String, nickname: String) async throws -> User

    func fetchUser(userID: String) async throws -> User

}
