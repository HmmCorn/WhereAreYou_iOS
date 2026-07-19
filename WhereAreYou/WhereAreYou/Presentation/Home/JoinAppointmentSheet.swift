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

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "약속 참여하기"
        label.font = .preferredFont(forTextStyle: .title3)
        label.textAlignment = .center
        return label
    }()

    private let codeField: UITextField = {
        let field = UITextField()
        field.placeholder = "코드 입력"
        field.font = .preferredFont(forTextStyle: .callout)
        field.textAlignment = .center
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.separator.cgColor
        field.layer.cornerRadius = 12
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
        return button
    }()

    private let cancelButton = UIButton.filled(title: "취소", background: .systemGray2, tint: .white)

    private let joinButton = UIButton.filled(title: "참여하기", background: .blue1, tint: .white)

    init() {
        super.init(frame: .zero)
        setUp()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init()")
    }

    private func setUp() {
        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = .white
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor

        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, joinButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 8
        buttonStack.distribution = .fillEqually

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        codeField.translatesAutoresizingMaskIntoConstraints = false
        pasteButton.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(codeField)
        addSubview(pasteButton)
        addSubview(buttonStack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 19),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            codeField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 22),
            codeField.heightAnchor.constraint(equalToConstant: 32),
            codeField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            codeField.trailingAnchor.constraint(equalTo: pasteButton.leadingAnchor, constant: -8),

            pasteButton.centerYAnchor.constraint(equalTo: codeField.centerYAnchor),
            pasteButton.heightAnchor.constraint(equalToConstant: 32),
            pasteButton.widthAnchor.constraint(equalToConstant: 90),
            pasteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),

            buttonStack.topAnchor.constraint(equalTo: codeField.bottomAnchor, constant: 20),
            buttonStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            buttonStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            buttonStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -31),
            cancelButton.heightAnchor.constraint(equalToConstant: 35),
            joinButton.heightAnchor.constraint(equalToConstant: 35)
        ])

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
