//
//  TransportType+Color.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-14.
//

import UIKit

extension TransportType {
    var color: UIColor {
        switch self {
        case .walk: return .systemBrown
        case .car: return .systemIndigo
        case .transit: return .systemGreen
        case .bicycle: return .systemYellow
        }
    }
}
