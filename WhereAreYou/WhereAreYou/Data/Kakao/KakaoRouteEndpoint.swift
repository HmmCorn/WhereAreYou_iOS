//
//  KakaoRouteEndpoint.swift
//  WhereAreYou
//
//  Created by 김성훈 on 10/30/26.
//

import Foundation

/// 카카오 길찾기 API 요청
enum KakaoRouteEndpoint {
    /// 도보 경로 조회
    case walk(start: Coordinate, end: Coordinate)
    /// 대중교통 경로 조회, 현재 시각 기준
    case transit(start: Coordinate, end: Coordinate)
}

extension KakaoRouteEndpoint: Endpoint {

    var baseURL: String { "https://dapi.kakao.com" }

    var path: String {
        switch self {
        case .walk:
            return "/v2/routing/walk"
        case .transit:
            return "/v2/routing/publictraffic"
        }
    }

    var method: HTTPMethod { .get }

    var queryItems: [URLQueryItem] {
        switch self {
        case .walk(let start, let end), .transit(let start, let end):
            return [
                URLQueryItem(name: "start_x", value: "\(start.longitude)"),
                URLQueryItem(name: "start_y", value: "\(start.latitude)"),
                URLQueryItem(name: "end_x", value: "\(end.longitude)"),
                URLQueryItem(name: "end_y", value: "\(end.latitude)")
            ]
        }
    }

    var headers: [String: String] {
        ["Authorization": "KakaoAK \(APIKey.kakaoRestAPIKey)"]
    }
}
