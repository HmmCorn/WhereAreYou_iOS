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

    private let card = CardContainerView(headerStyle: .title("약속 참여하기"))

    private let codeField: UITextField = {
        let field = UITextField()
        field.placeholder = "코드 입력"
        field.font = .preferredFont(forTextStyle: .callout)
        field.textAlignment = .center
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.separator.cgColor
        field.layer.cornerRadius = 12
        field.heightAnchor.constraint(equalToConstant: 32).isActive = true
        return field
    }()

    private let pasteButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "붙여넣기"
        config.baseForegroundColor = .secondaryLabel
        config.image = UIImage(systemName: "document.on.clipboard")
        config.imagePlacement = .leading
        config.imagePadding = 6
        config.cornerStyle = .fixed
        config.background.cornerRadius = 12
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .preferredFont(forTextStyle: .caption2)
            return outgoing
        }
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(
            font: .preferredFont(forTextStyle: .caption2)
        )
        let button = UIButton(configuration: config)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.separator.cgColor
        button.widthAnchor.constraint(equalToConstant: 90).isActive = true
        button.heightAnchor.constraint(equalToConstant: 32).isActive = true
        return button
    }()

    private let cancelButton: UIButton = {
        let button = UIButton.filled(title: "취소", background: .systemGray2, tint: .white)
        button.heightAnchor.constraint(equalToConstant: 35).isActive = true
        return button
    }()

    private let joinButton: UIButton = {
        let button = UIButton.filled(title: "참여하기", background: .blue1, tint: .white)
        button.heightAnchor.constraint(equalToConstant: 35).isActive = true
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
        fieldStack.isLayoutMarginsRelativeArrangement = true
        fieldStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24)

        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, joinButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 8
        buttonStack.distribution = .fillEqually
        buttonStack.isLayoutMarginsRelativeArrangement = true
        buttonStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24)

        card.contentStack.addArrangedSubview(fieldStack)
        card.contentStack.addArrangedSubview(buttonStack)
        card.contentStack.setCustomSpacing(20, after: fieldStack)

        pasteButton.addAction(UIAction { [weak self] _ in
            self?.pasteTapped()
        }, for: .touchUpInside)

        cancelButton.addAction(UIAction { [weak self] _ in
            self?.cancelTapped()
        }, for: .touchUpInside)

        joinButton.addAction(UIAction { [weak self] _ in
            self?.joinTapped()
        }, for: .touchUpInside)
    }

    private func pasteTapped() {
        print("붙여넣기 tapped")
    }

    private func cancelTapped() {
        onCancel?()
    }

    private func joinTapped() {
        print("참여하기 tapped")
        onJoin?(codeField.text ?? "")
    }

}
