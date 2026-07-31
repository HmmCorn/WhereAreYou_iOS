//
//  UIColor+ParticipantPalette.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/31/26.
//

import UIKit

extension UIColor {

    /// 참여자 수(count)만큼 hue를 균등 분할해 서로 가장 멀리 떨어진 색상을 만듦
    static func participantColors(count: Int) -> [UIColor] {
        guard count > 0 else { return [] }

        return (0..<count).map { index in
            UIColor(
                hue: CGFloat(index) / CGFloat(count),
                saturation: 0.8,
                brightness: 0.75,
                alpha: 1
            )
        }
    }

}
