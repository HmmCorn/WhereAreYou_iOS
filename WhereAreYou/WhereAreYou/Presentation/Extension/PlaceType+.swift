//
//  PlaceType+.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-16.
//

import Foundation

extension PlaceType {

    var title: String {
        switch self {
        case .subway: return "지하철 출구"
        case .restaurant: return "식당"
        case .cafe: return "카페"
        case .hospital: return "병원"
        case .station: return "정류장"
        case .shop: return "쇼핑"
        case .other: return "기타"
        }
    }

    var color: ColorAsset {
        switch self {
        case .subway: return .green
        case .restaurant: return .yellow
        case .cafe: return .orange
        case .hospital: return .indigo
        case .station: return .blue
        case .shop: return .red
        case .other: return .brown
        }
    }

}
