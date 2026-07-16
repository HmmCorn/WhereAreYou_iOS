//
//  AppointmentFieldsBox.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-14.
//

import UIKit

final class AppointmentFieldsBox: UIView {

    var onNameChanged: ((String) -> Void)?
    var onDateRowTap: (() -> Void)?
    var onPlaceRowTap: (() -> Void)?
    var onMapButtonTap: (() -> Void)?

    var name: String? {
        get { nameField.text }
        set { nameField.text = newValue }
    }
    var dateText: String? {
        get { dateRow.text }
        set { dateRow.text = newValue }
    }
    var placeText: String? {
        get { placeRow.text }
        set { placeRow.text = newValue }
    }

    private let nameField = TextFieldRow(icon: UIImage(systemName: "tag"), placeholder: "약속")
    private let dateRow = ButtonRow(icon: UIImage(systemName: "calendar"), placeholder: "날짜와 시간을 선택해주세요.")
    private let placeRow = ButtonRow(icon: UIImage(systemName: "location.circle"), placeholder: "장소를 선택해주세요.")

    private let mapButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "map"), for: .normal)
        button.tintColor = .blue2
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.separator.cgColor
        button.layer.cornerRadius = 12
        return button
    }()

    init() {
        super.init(frame: .zero)
        setUp()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init()")
    }

    private func setUp() {
        mapButton.addTarget(self, action: #selector(mapTapped), for: .touchUpInside)
        mapButton.widthAnchor.constraint(equalToConstant: 45).isActive = true

        let placeRowContent = UIStackView(arrangedSubviews: [placeRow, mapButton])
        placeRowContent.axis = .horizontal
        placeRowContent.spacing = 2
        placeRowContent.alignment = .fill

        let stack = UIStackView(arrangedSubviews: [
            labeledSection(title: "약속 이름", content: nameField),
            labeledSection(title: "날짜 및 시간", content: dateRow),
            labeledSection(title: "장소", content: placeRowContent)
        ])
        stack.axis = .vertical
        stack.spacing = 15
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        dateRow.onTap = { [weak self] in self?.onDateRowTap?() }
        placeRow.onTap = { [weak self] in self?.onPlaceRowTap?() }
        nameField.onTextChanged = { [weak self] text in self?.onNameChanged?(text) }
    }

    private func labeledSection(title: String, content: UIView) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = UIFont.preferredFont(forTextStyle: .footnote)

        let stack = UIStackView(arrangedSubviews: [label, content])
        stack.axis = .vertical
        stack.spacing = 3
        return stack
    }

    @objc private func mapTapped() { onMapButtonTap?() }

}
