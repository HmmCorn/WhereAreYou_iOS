//
//  TextFieldRow.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-14.
//

import UIKit

// MARK: - TextFieldRow

final class TextFieldRow: UIView {

    var onTextChanged: ((String) -> Void)?

    var text: String? {
        get { textField.text }
        set { textField.text = newValue }
    }

    private let iconView = UIImageView()
    private let textField = UITextField()

    init(icon: UIImage?, placeholder: String) {
        super.init(frame: .zero)
        iconView.image = icon
        iconView.tintColor = .label
        iconView.contentMode = .scaleAspectFit
        textField.placeholder = placeholder
        textField.font = UIFont.preferredFont(forTextStyle: .caption1)
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

        let stack = UIStackView(arrangedSubviews: [iconView, textField])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
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

        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }

    @objc private func textChanged() { onTextChanged?(textField.text ?? "") }
    
}
