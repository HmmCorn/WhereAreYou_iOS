//
//  SessionValidationService.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-20.
//

import Foundation

/// 세션 검증 결과
enum SessionValidationResult {
    case valid
    case networkError
    case invalid
}

/// 세션 검증 서비스 — 현재 로그인된 유저가 유효한지 확인
protocol SessionValidationService {

    var currentUserID: String? { get }

    func validate() async -> SessionValidationResult

}
