//
//  TransportType+.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-14.
//

import Foundation

extension TransportType {

    var name: String {
        switch self {
        case .walk: return "걷기"
        case .car: return "자동차"
        case .transit: return "대중교통"
        }
    }

    var icon: String {
        switch self {
        case .walk: return "figure.walk"
        case .car: return "car"
        case .transit: return "bus"
        }
    }

    var color: ColorAsset {
        switch self {
        case .walk: return .green
        case .car: return .indigo
        case .transit: return .yellow
        }
    }

}
