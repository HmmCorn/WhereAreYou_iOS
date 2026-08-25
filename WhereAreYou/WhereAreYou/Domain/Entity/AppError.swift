//
//  AppError.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-26.
//

import Foundation

/// 앱 공통 에러 타입 — Firebase 등 외부 에러를 앱 수준으로 변환한 결과
enum AppError: Error {

    case network
    case notAuthenticated
    case permissionDenied
    case notFound
    case alreadyExists
    case unknown(Error)

}
