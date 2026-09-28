//
//  KakaoLocalEndpoint.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/29/26.
//

import Foundation

/// 카카오 로컬 API 요청
enum KakaoLocalEndpoint {
    /// 키워드로 장소 검색
    case keyword(query: String)
    /// 좌표 반경 내 카테고리 검색, 거리순 정렬
    case category(code: String, coordinate: Coordinate, radiusMeters: Int)
    /// 좌표 -> 주소 변환
    case coord2address(coordinate: Coordinate)
}

extension KakaoLocalEndpoint: Endpoint {

    var baseURL: String { "https://dapi.kakao.com" }

    var path: String {
        switch self {
        case .keyword:
            return "/v2/local/search/keyword.json"
        case .category:
            return "/v2/local/search/category.json"
        case .coord2address:
            return "/v2/local/geo/coord2address.json"
        }
    }

    var method: HTTPMethod { .get }

    var queryItems: [URLQueryItem] {
        switch self {
        case .keyword(let query):
            return [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "size", value: "15")
            ]
        case .category(let code, let coordinate, let radiusMeters):
            return [
                URLQueryItem(name: "category_group_code", value: code),
                URLQueryItem(name: "x", value: "\(coordinate.longitude)"),
                URLQueryItem(name: "y", value: "\(coordinate.latitude)"),
                URLQueryItem(name: "radius", value: "\(radiusMeters)"),
                URLQueryItem(name: "sort", value: "distance")
            ]
        case .coord2address(let coordinate):
            return [
                URLQueryItem(name: "x", value: "\(coordinate.longitude)"),
                URLQueryItem(name: "y", value: "\(coordinate.latitude)")
            ]
        }
    }

    var headers: [String: String] {
        ["Authorization": "KakaoAK \(APIKey.kakaoRestAPIKey)"]
    }
}
