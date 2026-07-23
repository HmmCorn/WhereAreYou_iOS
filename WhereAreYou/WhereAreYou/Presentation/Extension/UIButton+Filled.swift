//
//  UIButton+Filled.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-14.
//

import UIKit

// MARK: - 꽉 찬 스타일의 버튼

extension UIButton {
    static func filled(
        title: String,
        background: UIColor?,
        tint: UIColor,
        font: UIFont.TextStyle? = nil,
        edgeInsets: NSDirectionalEdgeInsets = .init(top: 8, leading: 0, bottom: 8, trailing: 0)
    ) -> UIButton {
        
        var config = UIButton.Configuration.filled()
        if let font {
            var attributedTitle = AttributedString(title)
            attributedTitle.font = .preferredFont(forTextStyle: font)
            config.attributedTitle = attributedTitle
        } else {
            config.title = title
        }
        config.baseBackgroundColor = background
        config.baseForegroundColor = tint
        config.contentInsets = edgeInsets

        let button = UIButton(configuration: config)
        button.layer.cornerRadius = 12

        return button
    }
}
