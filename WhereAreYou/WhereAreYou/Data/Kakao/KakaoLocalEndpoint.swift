//
//  KakaoLocalEndpoint.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/29/26.
//

import Foundation

/// 카카오 키워드 검색 정렬 기준
enum KakaoKeywordSort {
    /// 정확도순 (카카오 기본값)
    case accuracy
    /// 기준 좌표와 가까운 순
    case distance
}

/// 카카오 로컬 API 요청
enum KakaoLocalEndpoint {
    /// 키워드로 장소 검색, 좌표를 넘기면 응답에 거리(m)가 채워짐
    case keyword(query: String, page: Int = 1, coordinate: Coordinate? = nil, sort: KakaoKeywordSort = .accuracy)
    /// 좌표 반경 내 카테고리 검색, 거리순 정렬
    case category(code: KakaoCategoryGroupCode, coordinate: Coordinate, radiusMeters: Int)
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
        case .keyword(let query, let page, let coordinate, let sort):
            var items = [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "size", value: "15"),
                URLQueryItem(name: "page", value: "\(page)")
            ]
            if let coordinate {
                items.append(URLQueryItem(name: "x", value: "\(coordinate.longitude)"))
                items.append(URLQueryItem(name: "y", value: "\(coordinate.latitude)"))
                if sort == .distance {
                    items.append(URLQueryItem(name: "sort", value: "distance"))
                }
            }
            return items
        case .category(let code, let coordinate, let radiusMeters):
            return [
                URLQueryItem(name: "category_group_code", value: code.rawValue),
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
