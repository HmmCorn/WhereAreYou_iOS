//
//  FCMTokenService.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-20.
//

import Foundation

/// FCM 토큰 서비스 — 현재 로그인된 유저의 FCM 디바이스 토큰 저장·삭제
protocol FCMTokenService {

    func save(token: String) async throws

    func deleteForCurrentUser() async throws

}
