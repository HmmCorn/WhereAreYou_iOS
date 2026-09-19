//
//  FCMTokenRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-19.
//

import Foundation

/// FCM 디바이스 토큰 저장소 — Firestore 유저 문서의 fcmToken 필드 관리
protocol FCMTokenRepository {

    func save(token: String, forUserID: String) async throws

    func delete(forUserID: String) async throws

}
