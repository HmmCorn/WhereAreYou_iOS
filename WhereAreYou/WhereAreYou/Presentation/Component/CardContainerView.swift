//
//  CardContainerView.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-14.
//

import UIKit

// MARK: - 헤더 구성이 선택적인, 그림자 효과가 있는 카드 UI
//       - HeaderStyle로 헤더 형태(없음 / 타이틀만 / 타이틀+닫기버튼)를 명시적으로 선택한다

final class CardContainerView: UIView {

    enum HeaderStyle {
        case none
        case title(String)
        case titleWithCloseButton(String)
    }

    let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 15
        return stack
    }()

    var onClose: (() -> Void)?

    private let headerStyle: HeaderStyle

    init(headerStyle: HeaderStyle = .none) {
        self.headerStyle = headerStyle
        super.init(frame: .zero)
        setUp()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init(headerStyle:)")
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
        switch headerStyle {
        case .none:
            return nil

        case .title(let title):
            let titleLabel = makeTitleLabel(text: title)
            let headerContainer = UIView()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            headerContainer.addSubview(titleLabel)
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
                titleLabel.topAnchor.constraint(equalTo: headerContainer.topAnchor),
                titleLabel.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor)
            ])
            return headerContainer

        case .titleWithCloseButton(let title):
            let titleLabel = makeTitleLabel(text: title)
            let closeButton = makeCloseButton()
            let headerContainer = UIView()

            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            headerContainer.addSubview(closeButton)
            headerContainer.addSubview(titleLabel)

            NSLayoutConstraint.activate([
                closeButton.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
                closeButton.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
                closeButton.widthAnchor.constraint(equalToConstant: 28),
                closeButton.heightAnchor.constraint(equalToConstant: 28),

                titleLabel.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
                titleLabel.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
                titleLabel.topAnchor.constraint(equalTo: headerContainer.topAnchor),
                titleLabel.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor)
            ])
            return headerContainer
        }
    }

    private func makeTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        return label
    }

    private func makeCloseButton() -> UIButton {
        let button = UIButton(type: .close)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }

    @objc private func closeTapped() { onClose?() }

}
