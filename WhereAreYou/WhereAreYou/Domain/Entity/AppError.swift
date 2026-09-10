//
//  AppError.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-26.
//

import Foundation

/// 앱 공통 에러 타입 — Firebase 등 외부 에러를 앱 수준으로 변환한 결과
enum AppError: LocalizedError {

    case network
    case notAuthenticated
    case permissionDenied
    case notFound
    case alreadyExists
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .network:
            return "네트워크 연결을 확인해 주세요."
        case .notAuthenticated:
            return "인증에 실패했습니다. 다시 시도해 주세요."
        case .permissionDenied:
            return "접근 권한이 없습니다."
        case .notFound:
            return "요청한 정보를 찾을 수 없습니다."
        case .alreadyExists:
            return "이미 존재하는 데이터입니다."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다. 다시 시도해 주세요."
        }
    }

}
