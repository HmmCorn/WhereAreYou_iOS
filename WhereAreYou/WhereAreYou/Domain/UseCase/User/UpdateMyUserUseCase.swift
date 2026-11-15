//
//  UpdateMyUserUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-11-15.
//

import Foundation

/// 내 유저 정보(프로필·위치 공유 범위·전체 알림)를 수정하고 저장된 값을 돌려준다 — nil인 항목은 변경하지 않는다
final class UpdateMyUserUseCase {

    private let authRepository: AuthRepository
    private let userRepository: UserRepository

    init(authRepository: AuthRepository, userRepository: UserRepository) {
        self.authRepository = authRepository
        self.userRepository = userRepository
    }

    func execute(
        nickname: String? = nil,
        profileImage: String? = nil,
        locationSharingScope: LocationSharingScope? = nil,
        isNotificationEnabled: Bool? = nil
    ) async throws -> User {
        guard let userID = authRepository.currentUserID else {
            throw AppError.notAuthenticated
        }
        return try await userRepository.updateUser(
            userID: userID,
            nickname: nickname,
            profileImage: profileImage,
            locationSharingScope: locationSharingScope,
            isNotificationEnabled: isNotificationEnabled
        )
    }

}
