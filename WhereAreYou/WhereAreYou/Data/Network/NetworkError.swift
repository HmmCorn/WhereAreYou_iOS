//
//  NetworkError.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/29/26.
//

import Foundation

/// URLSession 기반 네트워크 요청에서 발생하는 에러
enum NetworkError: Error {

    /// Endpoint로부터 URLRequest 생성 실패
    case invalidURL
    /// HTTPURLResponse가 아닌 응답
    case invalidResponse
    /// 2xx가 아닌 상태 코드
    case httpStatus(Int)
    /// 응답 바디 디코딩 실패
    case decoding(Error)
    /// URLSession 자체의 전송 실패
    case transport(Error)
    /// 응답 자체는 성공했으나 원하는 결과가 없음
    case emptyResult
}

extension NetworkError {

    /// AppError로 변환
    var appError: AppError {
        switch self {
        case .invalidURL, .invalidResponse, .decoding:
            return .unknown(self)
        case .httpStatus(let code):
            switch code {
            case 401, 403:
                return .permissionDenied
            case 404:
                return .notFound
            default:
                return .unknown(self)
            }
        case .transport(let error):
            let nsError = error as NSError
            return nsError.domain == NSURLErrorDomain ? .network : .unknown(error)
        case .emptyResult:
            return .notFound
        }
    }
}
