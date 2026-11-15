//
//  UserRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-03.
//

import Foundation

/// 사용자 저장소 — Firestore 유저 문서 생성, 조회, 수정
protocol UserRepository {

    func createUserIfNeeded(userID: String, nickname: String) async throws -> User

    func fetchUser(userID: String) async throws -> User

    /// 여러 사용자를 한 번에 조회해 ID별로 돌려준다. 없는 사용자는 결과에서 빠진다
    func fetchUsers(userIDs: Set<String>) async throws -> [String: User]

    /// nil인 항목은 변경하지 않는다
    func updateUser(
        userID: String,
        nickname: String?,
        profileImage: String?,
        locationSharingScope: LocationSharingScope?,
        isNotificationEnabled: Bool?
    ) async throws -> User

}
