//
//  JoinAppointmentSheet.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/16/26.
//

import UIKit

// MARK: - "약속 참여하기" 버튼 탭 시 뜨는 약속 코드 입력 모달

final class JoinAppointmentSheet: UIView {

    var onCancel: (() -> Void)?
    var onJoin: ((String) -> Void)?

    private let card = CardContainerView(title: "약속 코드 입력")

    private let codeField: UITextField = {
        let field = UITextField()
        field.placeholder = "코드를 입력해주세요"
        field.borderStyle = .roundedRect
        return field
    }()

    private lazy var pasteButton = UIButton.filled(
        title: "붙여넣기",
        background: .systemGray2,
        tint: .white
    )

    private lazy var cancelButton = UIButton.filled(
        title: "취소",
        background: .systemGray4,
        tint: .label
    )

    private lazy var joinButton = UIButton.filled(
        title: "참여하기",
        background: .blue2,
        tint: .white
    )

    init() {
        super.init(frame: .zero)
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

        let fieldStack = UIStackView(arrangedSubviews: [codeField, pasteButton])
        fieldStack.axis = .horizontal
        fieldStack.spacing = 8

        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, joinButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 8
        buttonStack.distribution = .fillEqually

        card.contentStack.addArrangedSubview(fieldStack)
        card.contentStack.addArrangedSubview(buttonStack)

        card.onClose = { [weak self] in self?.onCancel?() }
        pasteButton.addTarget(self, action: #selector(pasteTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        joinButton.addTarget(self, action: #selector(joinTapped), for: .touchUpInside)
    }

    @objc private func pasteTapped() {
        print("붙여넣기 tapped")
    }

    @objc private func cancelTapped() {
        onCancel?()
    }

    @objc private func joinTapped() {
        print("참여하기 tapped, code: \(codeField.text ?? "")")
        onJoin?(codeField.text ?? "")
    }

}
