//
//  AppointmentConfirmCard.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-14.
//

import UIKit

final class AppointmentConfirmCard: UIView {

    var onCopyCodeTap: (() -> Void)?
    var onConfirmTap: (() -> Void)?

    private let card = CardContainerView(headerStyle: .title("약속을 만들었어요!"))

    private let nameRow = InfoRow(icon: UIImage(systemName: "tag"))
    private let dateRow = InfoRow(icon: UIImage(systemName: "calendar"))
    private let placeRow = InfoRow(icon: UIImage(systemName: "location.circle"))

    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()

    private let codeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        label.layer.opacity = 0.6
        label.textAlignment = .center
        return label
    }()

    private lazy var copyButton = UIButton.filled(title: "코드 복사하기", background: .systemGray2, tint: .white)
    private lazy var confirmButton = UIButton.filled(title: "약속으로 이동하기", background: .blue2, tint: .white)

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

        let infoStack = UIStackView(arrangedSubviews: [nameRow, dateRow, placeRow])
        infoStack.axis = .vertical
        infoStack.spacing = 10

        footerStack.addArrangedSubview(copyButton)
        footerStack.addArrangedSubview(confirmButton)

        card.contentStack.addArrangedSubview(infoStack)
        card.contentStack.addArrangedSubview(divider)
        card.contentStack.addArrangedSubview(codeLabel)
        card.contentStack.addArrangedSubview(footerStack)

        copyButton.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
    }

    private func configure(with data: AppointmentInfo) {
        nameRow.text = data.title
        dateRow.text = data.date?.koreanDateString ?? "미정"
        placeRow.text = data.location?.title ?? "미정"
        codeLabel.text = "약속 코드 : \(data.code)"
    }

    @objc private func copyTapped() { onCopyCodeTap?() }
    @objc private func confirmTapped() { onConfirmTap?() }

}
