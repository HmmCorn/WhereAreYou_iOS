//
//  KakaoTransitLineColor.swift
//  WhereAreYou
//
//  Created by 김성훈 on 10/30/26.
//

import Foundation

/// 카카오 대중교통 노선 정보 -> 노선 대표 색 hex
enum KakaoTransitLineColor {

    /// 지하철 노선명 기준 색, 매핑에 없으면 nil
    /// 지방 도시철도도 "1호선"처럼 같은 이름으로 와서 수도권 색으로 표시됨
    static func subwayColorHex(lineName: String) -> String? {
        subwayColorHexes[lineName]
    }

    // MARK: - Private

    /// 카카오 응답의 vehicles[].name -> 색
    private static let subwayColorHexes: [String: String] = [
        "1호선": "#0052A4",
        "2호선": "#00A84D",
        "3호선": "#EF7C1C",
        "4호선": "#00A5DE",
        "5호선": "#996CAC",
        "6호선": "#CD7C2F",
        "7호선": "#747F00",
        "8호선": "#E6186C",
        "9호선": "#BDB092",
        "신분당선": "#D4003B",
        "수인분당선": "#F5A200",
        "경의중앙선": "#77C4A3",
        "공항철도": "#0090D2",
        "경춘선": "#0C8E72",
        "경강선": "#003DA5",
        "서해선": "#8FC31F",
        "GTX-A": "#9A6292",
        "인천1호선": "#7CA8D5",
        "인천2호선": "#ED8B00",
        "김포골드": "#AD8605",
        "신림선": "#6789CA",
        "우이신설": "#B0CE18",
        "에버라인": "#509F22",
        "의정부 경전철": "#FDA600"
    ]
}
