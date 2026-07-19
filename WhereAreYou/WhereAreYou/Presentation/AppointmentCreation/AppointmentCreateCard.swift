//
//  AppointmentCreateCard.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-14.
//

import UIKit

final class AppointmentCreateCard: UIView {

    var onNameChanged: ((String) -> Void)?
    var onDateRowTap: (() -> Void)?
    var onPlaceRowTap: (() -> Void)?
    var onMapButtonTap: (() -> Void)?
    var onCreateTap: (() -> Void)?

    private let card = CardContainerView(headerStyle: .title("약속 만들기"))
    private let fieldsBox = AppointmentFieldsBox()
    private lazy var createButton = UIButton.filled(title: "생성하기", background: .blue2, tint: .white)

    init() {
        super.init(frame: .zero)
        fieldsBox.name = "약속"
        setUp()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init()")
    }

    private func setUp() {
        translatesAutoresizingMaskIntoConstraints = false
        card.translatesAutoresizingMaskIntoConstraints = false
        addSubview(card)
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: topAnchor),
            card.leadingAnchor.constraint(equalTo: leadingAnchor),
            card.trailingAnchor.constraint(equalTo: trailingAnchor),
            card.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        card.contentStack.addArrangedSubview(fieldsBox)
        card.contentStack.addArrangedSubview(createButton)
        card.contentStack.setCustomSpacing(20, after: fieldsBox)

        fieldsBox.onNameChanged = { [weak self] text in self?.onNameChanged?(text) }
        fieldsBox.onDateRowTap = { [weak self] in self?.onDateRowTap?() }
        fieldsBox.onPlaceRowTap = { [weak self] in self?.onPlaceRowTap?() }
        fieldsBox.onMapButtonTap = { [weak self] in self?.onMapButtonTap?() }
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)

        let dismissKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissKeyboardGesture.cancelsTouchesInView = false
        dismissKeyboardGesture.delegate = self
        addGestureRecognizer(dismissKeyboardGesture)
    }

    @objc private func createTapped() { onCreateTap?() }
    @objc private func dismissKeyboard() { endEditing(true) }

}

extension AppointmentCreateCard: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        !(touch.view is UITextField)
    }
}
