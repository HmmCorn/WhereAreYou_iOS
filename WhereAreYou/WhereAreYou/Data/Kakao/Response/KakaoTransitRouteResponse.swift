//
//  KakaoTransitRouteResponse.swift
//  WhereAreYou
//
//  Created by 김성훈 on 10/30/26.
//

import Foundation

/// 카카오 대중교통 경로 조회 응답
struct KakaoTransitRouteResponse: Decodable {
    /// 탐색 결과 상태, OK가 아니면 routes 없음
    let status: String
    let routes: [KakaoTransitRoute]?
}

/// 대중교통 추천 경로
struct KakaoTransitRoute: Decodable {
    let properties: KakaoTransitRouteProperties
    let steps: [KakaoTransitStep]
}

/// 대중교통 경로 전체 요약, 출발·도착 도보 포함
struct KakaoTransitRouteProperties: Decodable {
    /// 전체 거리(m)
    let totalDistance: Double
    /// 전체 소요 시간(초)
    let totalTime: Double
}

/// 이동수단 단위 구간, 출발·도착 도보는 빠짐
struct KakaoTransitStep: Decodable {
    let properties: KakaoTransitStepProperties
    let path: KakaoRoutePath
}

/// 구간 정보
struct KakaoTransitStepProperties: Decodable {
    /// BUS, SUBWAY, WALKING
    let type: String
    /// 구간 거리(m)
    let distance: Double
    /// 구간 소요 시간(초)
    let time: Double
    /// 탑승 ~ 하차 정류장 목록
    let stops: [KakaoTransitStop]?
    /// 이 구간을 갈 수 있는 노선 목록, 도보 구간은 없음
    let vehicles: [KakaoTransitVehicle]?
}

/// 정류장·역
struct KakaoTransitStop: Decodable {
    let name: String
}

/// 노선
struct KakaoTransitVehicle: Decodable {
    /// 노선명 (예: "146", "2호선")
    let name: String
    /// 노선 종류 (예: "간선", "마을", "일반")
    let type: String
}
