//
//  PlaceType.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-14.
//

enum PlaceType {

    case subway
    case restaurant
    case cafe
    case hospital
    case station
    case shop
    case other

    var title: String {
        switch self {
        case .subway: return "지하철역"
        case .restaurant: return "레스토랑"
        case .cafe: return "카페"
        case .hospital: return "병원"
        case .station: return "정류장"
        case .shop: return "쇼핑"
        case .other: return "기타"
        }
    }
    
}
