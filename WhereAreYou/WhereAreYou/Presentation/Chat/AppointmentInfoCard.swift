//
//  AppointmentInfoCard.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-14.
//

import UIKit

final class AppointmentInfoCard: UIView {

    var onClose: (() -> Void)?
    var onDateRowTap: (() -> Void)?
    var onPlaceRowTap: (() -> Void)?
    var onMapButtonTap: (() -> Void)?
    var onLeaveTap: (() -> Void)?
    var onCopyCodeTap: (() -> Void)?

    private let card = CardContainerView(title: "약속 정보", showsCloseButton: true)
    private let fieldsBox = AppointmentFieldsBox()

    private let memberSectionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        return label
    }()

    private let memberStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .top
        return stack
    }()

    private lazy var memberSection: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [memberSectionLabel, memberStack])
        stack.axis = .vertical
        stack.spacing = 3
        stack.alignment = .leading
        return stack
    }()

    private let codeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        label.layer.opacity = 0.6
        label.textAlignment = .center
        return label
    }()

    private lazy var leaveButton = UIButton.filled(
        title: "약속 나가기",
        background: .customRed.withAlphaComponent(0.8),
        tint: .white
    )
    private lazy var copyButton = UIButton.filled(
        title: "코드 복사하기",
        background: .systemGray2,
        tint: .white
    )

    private let footerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fillEqually
        return stack
    }()

    init(data: AppointmentInfo) {
        super.init(frame: .zero)
        setUp()
        configure(with: data)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init(data:)")
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

        footerStack.addArrangedSubview(leaveButton)
        footerStack.addArrangedSubview(copyButton)

        card.contentStack.addArrangedSubview(fieldsBox)
        card.contentStack.addArrangedSubview(memberSection)
        card.contentStack.addArrangedSubview(codeLabel)
        card.contentStack.addArrangedSubview(footerStack)

        card.onClose = { [weak self] in self?.onClose?() }
        fieldsBox.onDateRowTap = { [weak self] in self?.onDateRowTap?() }
        fieldsBox.onPlaceRowTap = { [weak self] in self?.onPlaceRowTap?() }
        fieldsBox.onMapButtonTap = { [weak self] in self?.onMapButtonTap?() }
        leaveButton.addTarget(self, action: #selector(leaveTapped), for: .touchUpInside)
        copyButton.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)

        let dismissKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissKeyboardGesture.cancelsTouchesInView = false
        dismissKeyboardGesture.delegate = self
        addGestureRecognizer(dismissKeyboardGesture)
    }

    private func configure(with data: AppointmentInfo) {
        fieldsBox.name = data.title
        fieldsBox.dateText = data.date?.koreanDateString ?? "미정"
        fieldsBox.placeText = data.location?.title ?? "미정"

        memberSectionLabel.text = "인원 (\(data.participants.count)명)"
        data.participants.forEach { member in
            memberStack.addArrangedSubview(ParticipantBox(member: member))
        }

        codeLabel.text = "약속 코드 : \(data.code)"
    }

    @objc private func leaveTapped() { onLeaveTap?() }
    @objc private func copyTapped() { onCopyCodeTap?() }
    @objc private func dismissKeyboard() { endEditing(true) }

}

extension AppointmentInfoCard: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        !(touch.view is UITextField)
    }
}
