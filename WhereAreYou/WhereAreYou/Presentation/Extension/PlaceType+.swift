//
//  PlaceType+.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-16.
//

import UIKit

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

    var color: UIColor {
        switch self {
        case .subway: return .systemGreen
        case .restaurant: return .systemYellow
        case .cafe: return .orange
        case .hospital: return .systemIndigo
        case .station: return .systemBlue
        case .shop: return .systemRed
        case .other: return .systemBrown
        }
    }

}
