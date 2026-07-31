//
//  UIColor+ParticipantPalette.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/31/26.
//

import UIKit

extension UIColor {

    /// 참여자 구분용 색상 팔레트
    /// TODO: 디자인 확정되면 전용 컬러셋으로 교체
    static let participantPalette: [UIColor] = (0..<16).map { index in
        UIColor(
            hue: CGFloat(index) / 16,
            saturation: 0.55,
            brightness: 0.85,
            alpha: 1
        )
    }

    /// participants 배열 내 순번(index) 기준으로 팔레트를 순환 배정
    static func participantColor(at index: Int) -> UIColor {
        participantPalette[index % participantPalette.count]
    }

}
