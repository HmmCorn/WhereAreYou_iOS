//
//  FCMInstallationIDService.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-20.
//

import Foundation

/// FCM 설치 ID 서비스 — 현재 로그인된 유저의 FCM 설치 ID(푸시 발송 대상) 저장·삭제
protocol FCMInstallationIDService {

    func save(installationID: String) async throws

    func deleteForCurrentUser() async throws

}
