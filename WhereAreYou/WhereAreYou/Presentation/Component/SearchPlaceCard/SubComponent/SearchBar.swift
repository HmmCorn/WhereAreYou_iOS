//
//  SearchBar.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-16.
//

import UIKit

final class SearchBar: UIView {

    var onTextChanged: ((String) -> Void)?
    var onSearchTap: (() -> Void)?

    var text: String? {
        get { textField.text }
        set { textField.text = newValue }
    }

    private let textField: UITextField = {
        var field = UITextField()
        field.placeholder = "장소를 검색해요."
        field.font = UIFont.preferredFont(forTextStyle: .footnote)
        field.adjustsFontForContentSizeCategory = true
        return field
    }()

    private let searchButton: UIButton = {
        var button = UIButton(type: .system)
        button.setImage(
            UIImage(systemName: "magnifyingglass"),
            for: .normal
        )
        button.tintColor = .blue1
        return button
    }()

    init() {
        super.init(frame: .zero)
        setUpLayout()
        setUpActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    private func setUpLayout() {
        layer.borderWidth = 1
        layer.borderColor = UIColor.separator.cgColor
        layer.cornerRadius = 12

        let stack = UIStackView(arrangedSubviews: [textField, searchButton])
        stack.axis = .horizontal
        stack.spacing = 2
        stack.alignment = .center
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 1, leading: 8, bottom: 1, trailing: 16)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        searchButton.widthAnchor.constraint(equalToConstant: 22).isActive = true
        searchButton.heightAnchor.constraint(equalToConstant: 22).isActive = true

        NSLayoutConstraint.activate([
            stack.heightAnchor.constraint(equalToConstant: 38),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - Actions

    private func setUpActions() {
        textField.addAction(UIAction { [weak self] _ in
            self?.onTextChanged?(self?.textField.text ?? "")
        }, for: .editingChanged)
        searchButton.addAction(UIAction { [weak self] _ in
            self?.onSearchTap?()
            self?.endEditing(true)
        }, for: .touchUpInside)
    }

}
