//
//  PlaceInputBox.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-22.
//

import UIKit

final class PlaceInputBox: UIView {

    var onDepartureTapped: (() -> Void)?
    var onArrivalTapped: (() -> Void)?
    var onDepartureClear: (() -> Void)?
    var onArrivalClear: (() -> Void)?
    var onCurrentLocationTapped: (() -> Void)?

    private let departureIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "location.fill"))
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let departureButton: UIButton = {
        let button = UIButton.filled(
            title: "출발",
            background: .clear,
            tint: .placeholderText,
            font: .body,
            edgeInsets: NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 0)
        )
        button.contentHorizontalAlignment = .leading
        return button
    }()

    private let currentLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "scope"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()

    private let departureClearButton = UIButton(type: .system)

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()

    private let arrivalIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "mappin"))
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let arrivalButton: UIButton = {
        let button = UIButton.filled(
            title: "도착",
            background: .clear,
            tint: .placeholderText,
            font: .body,
            edgeInsets: NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 0)
        )
        button.contentHorizontalAlignment = .leading
        return button
    }()

    private let arrivalClearButton = UIButton(type: .system)

    init() {
        super.init(frame: .zero)
        setUp()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init()")
    }

    func setDeparture(name: String?) {
        if let name {
            departureButton.configuration?.title = name
            departureButton.configuration?.baseForegroundColor = .label
            departureClearButton.isHidden = false
        } else {
            departureButton.configuration?.title = "출발"
            departureButton.configuration?.baseForegroundColor = .placeholderText
            departureClearButton.isHidden = true
        }
    }

    func setArrival(name: String?) {
        if let name {
            arrivalButton.configuration?.title = name
            arrivalButton.configuration?.baseForegroundColor = .label
            arrivalClearButton.isHidden = false
        } else {
            arrivalButton.configuration?.title = "도착"
            arrivalButton.configuration?.baseForegroundColor = .placeholderText
            arrivalClearButton.isHidden = true
        }
    }

    private func setUp() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 16
        layer.shadowOffset = CGSize(width: 0, height: 4)

        let iconSize: CGFloat = 24

        makeClearButton(departureClearButton)
        makeClearButton(arrivalClearButton)

        let departureRow = UIStackView(arrangedSubviews: [departureIcon, departureButton, currentLocationButton, departureClearButton])
        departureRow.axis = .horizontal
        departureRow.spacing = 12
        departureRow.alignment = .center

        departureRow.setCustomSpacing(5, after: departureIcon)

        let arrivalRow = UIStackView(arrangedSubviews: [arrivalIcon, arrivalButton, arrivalClearButton])
        arrivalRow.axis = .horizontal
        arrivalRow.spacing = 12
        arrivalRow.alignment = .center

        arrivalRow.setCustomSpacing(5, after: arrivalIcon)

        let mainStack = UIStackView(arrangedSubviews: [departureRow, separator, arrivalRow])
        mainStack.axis = .vertical
        mainStack.spacing = 0

        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),

            departureIcon.widthAnchor.constraint(equalToConstant: iconSize),
            departureIcon.heightAnchor.constraint(equalToConstant: iconSize),
            currentLocationButton.widthAnchor.constraint(equalToConstant: iconSize),
            currentLocationButton.heightAnchor.constraint(equalToConstant: iconSize),
            departureClearButton.widthAnchor.constraint(equalToConstant: iconSize),
            departureClearButton.heightAnchor.constraint(equalToConstant: iconSize),

            arrivalIcon.widthAnchor.constraint(equalToConstant: iconSize),
            arrivalIcon.heightAnchor.constraint(equalToConstant: iconSize),
            arrivalClearButton.widthAnchor.constraint(equalToConstant: iconSize),
            arrivalClearButton.heightAnchor.constraint(equalToConstant: iconSize),

            separator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),
            departureRow.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            arrivalRow.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
        ])

        departureButton.addAction(UIAction { [weak self] _ in
            self?.onDepartureTapped?()
        }, for: .touchUpInside)

        currentLocationButton.addAction(UIAction { [weak self] _ in
            self?.onCurrentLocationTapped?()
        }, for: .touchUpInside)

        departureClearButton.addAction(UIAction { [weak self] _ in
            self?.onDepartureClear?()
        }, for: .touchUpInside)

        arrivalButton.addAction(UIAction { [weak self] _ in
            self?.onArrivalTapped?()
        }, for: .touchUpInside)

        arrivalClearButton.addAction(UIAction { [weak self] _ in
            self?.onArrivalClear?()
        }, for: .touchUpInside)
    }

}

// MARK - Sub view makers

extension PlaceInputBox {

    private func makeClearButton(_ button: UIButton) {
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .tertiaryLabel
        button.isHidden = true
    }

}
