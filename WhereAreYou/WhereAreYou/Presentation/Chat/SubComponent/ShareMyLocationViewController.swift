//
//  ShareMyLocationViewController.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-03.
//

import UIKit

/// 내 위치 공유 확인 다이얼로그
final class ShareMyLocationViewController: UIViewController {

    var onConfirm: (() -> Void)?

    private let address: String
    private let dimView = UIView()
    private let card: CardContainerView

    init(address: String) {
        self.address = address
        self.card = CardContainerView(headerStyle: .title("내 위치 공유"))
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLayout()
        setUpActions()
    }

    private func setUpLayout() {
        dimView.backgroundColor = .black.withAlphaComponent(0.4)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimView)

        card.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(card)

        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        let locationIcon = UIImageView(image: UIImage(systemName: "location.fill"))
        locationIcon.tintColor = .blue2
        locationIcon.contentMode = .scaleAspectFit
        locationIcon.translatesAutoresizingMaskIntoConstraints = false
        locationIcon.widthAnchor.constraint(equalToConstant: 32).isActive = true
        locationIcon.heightAnchor.constraint(equalToConstant: 32).isActive = true

        let addressLabel = UILabel()
        addressLabel.text = address
        addressLabel.font = .preferredFont(forTextStyle: .body)
        addressLabel.textColor = .label
        addressLabel.numberOfLines = 0
        addressLabel.textAlignment = .center

        let descriptionLabel = UILabel()
        descriptionLabel.text = "이 위치를 공유하시겠습니까?"
        descriptionLabel.font = .preferredFont(forTextStyle: .subheadline)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.textAlignment = .center

        let confirmButton = UIButton.filled(
            title: "공유하기",
            background: .blue2,
            tint: .white,
            edgeInsets: NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        )
        confirmButton.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true) {
                self?.onConfirm?()
            }
        }, for: .touchUpInside)

        let cancelButton = UIButton.filled(
            title: "취소",
            background: .systemGray5,
            tint: .label,
            edgeInsets: NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        )
        cancelButton.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        }, for: .touchUpInside)

        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, confirmButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 10
        buttonStack.distribution = .fillEqually

        card.contentStack.addArrangedSubview(locationIcon)
        card.contentStack.addArrangedSubview(addressLabel)
        card.contentStack.addArrangedSubview(descriptionLabel)
        card.contentStack.addArrangedSubview(buttonStack)

        card.contentStack.alignment = .center
        card.contentStack.setCustomSpacing(8, after: addressLabel)
    }

    private func setUpActions() {
        card.onClose = { [weak self] in
            self?.dismiss(animated: true)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimTapped(_:)))
        dimView.addGestureRecognizer(tapGesture)
    }

    @objc private func dimTapped(_ gesture: UITapGestureRecognizer) {
        dismiss(animated: true)
    }

}
