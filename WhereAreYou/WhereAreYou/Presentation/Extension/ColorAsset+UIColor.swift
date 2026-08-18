//
//  ColorAsset+UIColor.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-18.
//

import UIKit

extension ColorAsset {

    var uiColor: UIColor {
        switch self {
        case .green: return .systemGreen
        case .yellow: return .systemYellow
        case .orange: return .orange
        case .indigo: return .systemIndigo
        case .blue: return .systemBlue
        case .red: return .systemRed
        case .brown: return .systemBrown
        }
    }

}
