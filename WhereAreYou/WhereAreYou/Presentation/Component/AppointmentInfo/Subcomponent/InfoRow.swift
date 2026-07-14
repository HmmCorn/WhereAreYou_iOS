//
//  InfoRow.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-14.
//

import UIKit

// MARK: - InfoRow

final class InfoRow: UIView {

    var text: String? {
        get { label.text }
        set { label.text = newValue }
    }

    private let iconView = UIImageView()
    private let label = UILabel()

    init(icon: UIImage?, text: String = "") {
        super.init(frame: .zero)
        iconView.image = icon
        iconView.tintColor = .secondaryLabel
        iconView.contentMode = .scaleAspectFit

        label.text = text
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel

        setUp()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUp() {
        let stack = UIStackView(arrangedSubviews: [iconView, label])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        iconView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 20).isActive = true

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

}
