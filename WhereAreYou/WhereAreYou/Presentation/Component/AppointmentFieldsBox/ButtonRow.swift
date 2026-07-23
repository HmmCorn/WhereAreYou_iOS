//
//  ButtonRow.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-14.
//

import UIKit

// MARK: - 아이콘과 텍스트를 테두리로 감싸는 커스텀 버튼 행 UI

final class ButtonRow: UIControl {

    var onTap: (() -> Void)?

    override var isHighlighted: Bool {
        didSet { updateHighlightAppearance() }
    }

    var text: String? {
        didSet {
            valueLabel.text = text ?? placeholder
            valueLabel.textColor = text == nil ? .placeholderText : .label
        }
    }

    private let placeholder: String
    private let iconView = UIImageView()
    private let valueLabel = UILabel()

    init(icon: UIImage?, placeholder: String) {
        self.placeholder = placeholder
        super.init(frame: .zero)
        iconView.image = icon
        iconView.tintColor = .label
        iconView.contentMode = .scaleAspectFit
        valueLabel.text = placeholder
        valueLabel.textColor = .placeholderText
        valueLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        setUp()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUp() {
        layer.borderWidth = 1
        layer.borderColor = UIColor.separator.cgColor
        layer.cornerRadius = 12
        isUserInteractionEnabled = true

        let stack = UIStackView(arrangedSubviews: [iconView, valueLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        iconView.widthAnchor.constraint(equalToConstant: 22).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 22).isActive = true
        heightAnchor.constraint(equalToConstant: 38).isActive = true

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }

    @objc private func tapped() { onTap?() }

    private func updateHighlightAppearance() {
        UIView.animate(withDuration: 0.12) {
            self.backgroundColor = self.isHighlighted ? UIColor.systemGray6 : .clear
        }
    }

}
