//
//  ButtonRow.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-14.
//

import UIKit

// MARK: - ButtonRow (탭하면 피커/지도를 여는 행 — 날짜, 장소)

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
        // TODO: Log 출력으로 수정 필요
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
