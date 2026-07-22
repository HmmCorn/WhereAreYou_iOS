//
//  IconLabel.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/16/26.
//

import UIKit

// MARK: - 아이콘 + 텍스트 한 줄
//       - 아이콘 크기는 텍스트 폰트 높이에 맞춰 자동 결정

final class IconLabel: UIView {

    var text: String? {
        get { label.text }
        set { label.text = newValue }
    }

    private let iconView = UIImageView()
    private let label = UILabel()

    init(
        iconName: String,
        text: String = "",
        font: UIFont = .preferredFont(forTextStyle: .footnote),
        color: UIColor = .secondaryLabel
    ) {
        super.init(frame: .zero)

        iconView.image = UIImage(systemName: iconName)
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit

        label.text = text
        label.font = font
        label.textColor = color

        setUp(iconSize: font.lineHeight)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUp(iconSize: CGFloat) {
        let stack = UIStackView(arrangedSubviews: [iconView, label])
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        iconView.widthAnchor.constraint(equalToConstant: iconSize).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: iconSize).isActive = true

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

}
