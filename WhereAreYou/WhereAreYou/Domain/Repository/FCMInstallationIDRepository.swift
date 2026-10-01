//
//  FCMInstallationIDRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-19.
//

import Foundation

/// FCM 설치 ID 저장소 — Firestore 유저 문서의 fcmInstallationID 필드 관리.
/// 서버는 이 값을 FCM 발송 대상(fid)으로 쓴다
protocol FCMInstallationIDRepository {

    func save(installationID: String, forUserID: String) async throws

    func delete(forUserID: String) async throws

}
