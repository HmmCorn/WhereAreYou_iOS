//
//  TransportType.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-14.
//

enum TransportType {

    case walk
    case car
    case transit
    case bicycle

    var name: String {
        switch self {
        case .walk: return "걷기"
        case .car: return "자동차"
        case .transit: return "대중교통"
        case .bicycle: return "자전거"
        }
    }

    var icon: String {
        switch self {
        case .walk: return "figure.walk"
        case .car: return "car"
        case .transit: return "bus"
        case .bicycle: return "bicycle"
        }
    }

}
