//
//  CardContainerView.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-14.
//

import UIKit

// MARK: - 선택적으로 헤더를 구성하고, 그림자 효과가 있는 카드 UI
//       - 헤더 구성: X 버튼과 타이틀

final class CardContainerView: UIView {

    let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 15
        return stack
    }()

    var onClose: (() -> Void)?

    private let closeButton: UIButton = {
        let button = UIButton(type: .close)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .label
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        return label
    }()

    private let title: String?
    private let showsCloseButton: Bool

    init(title: String? = nil, showsCloseButton: Bool = false) {
        self.title = title
        self.showsCloseButton = showsCloseButton
        super.init(frame: .zero)
        setUp()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init(title:showsCloseButton:)")
    }

    private func setUp() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 16
        layer.shadowOffset = CGSize(width: 0, height: 4)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])

        if let headerContainer = makeHeaderContainer() {
            contentStack.addArrangedSubview(headerContainer)
            contentStack.setCustomSpacing(25, after: headerContainer)
        }
    }

    private func makeHeaderContainer() -> UIView? {
        guard title != nil || showsCloseButton else { return nil }

        let headerContainer = UIView()
        closeButton.isHidden = !showsCloseButton
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(closeButton)

        var constraints = [
            closeButton.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            closeButton.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 28),
            closeButton.heightAnchor.constraint(equalToConstant: 28)
        ]

        if let title {
            titleLabel.text = title
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            headerContainer.addSubview(titleLabel)
            constraints += [
                titleLabel.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
                titleLabel.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
                titleLabel.topAnchor.constraint(equalTo: headerContainer.topAnchor),
                titleLabel.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor)
            ]
        } else {
            constraints += [
                closeButton.topAnchor.constraint(equalTo: headerContainer.topAnchor),
                closeButton.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor)
            ]
        }

        NSLayoutConstraint.activate(constraints)
        return headerContainer
    }

    @objc private func closeTapped() { onClose?() }

}
