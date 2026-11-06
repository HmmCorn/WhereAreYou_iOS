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
    /// 자동차 길찾기, 현재 시각 기준
    case car(origin: Coordinate, destination: Coordinate)
    /// 자동차 길찾기, 출발 시각의 교통 예측 기준
    case futureCar(origin: Coordinate, destination: Coordinate, departureTime: Date)
}

extension KakaoRouteEndpoint: Endpoint {

    var baseURL: String {
        switch self {
        case .walk, .transit:
            return "https://dapi.kakao.com"
        case .car, .futureCar:
            return "https://apis-navi.kakaomobility.com"
        }
    }

    var path: String {
        switch self {
        case .walk:
            return "/v2/routing/walk"
        case .transit:
            return "/v2/routing/publictraffic"
        case .car:
            return "/v1/directions"
        case .futureCar:
            return "/v1/future/directions"
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
        case .car(let origin, let destination):
            return Self.carQueryItems(origin: origin, destination: destination)
        case .futureCar(let origin, let destination, let departureTime):
            return Self.carQueryItems(origin: origin, destination: destination) + [
                URLQueryItem(name: "departure_time", value: Self.departureTimeFormatter.string(from: departureTime))
            ]
        }
    }

    var headers: [String: String] {
        ["Authorization": "KakaoAK \(APIKey.kakaoRestAPIKey)"]
    }

    // MARK: - Private

    /// 자동차 길찾기 공통 쿼리, 대안 경로 포함
    private static func carQueryItems(origin: Coordinate, destination: Coordinate) -> [URLQueryItem] {
        [
            URLQueryItem(name: "origin", value: "\(origin.longitude),\(origin.latitude)"),
            URLQueryItem(name: "destination", value: "\(destination.longitude),\(destination.latitude)"),
            URLQueryItem(name: "alternatives", value: "true")
        ]
    }

    /// 미래 길찾기 출발 시각 형식 (yyyyMMddHHmm, 한국 시간)
    private static let departureTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyyMMddHHmm"
        return formatter
    }()
}
