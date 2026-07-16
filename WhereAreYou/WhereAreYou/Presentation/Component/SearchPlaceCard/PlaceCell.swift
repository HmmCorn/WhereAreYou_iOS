//
//  PlaceCell.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-16.
//

import UIKit

final class PlaceCell: UIView {

    var onButtonTap: (() -> Void)?

    private let nameLabel: UILabel = {
        var label = UILabel()
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .callout)
        return label
    }()

    private let addressLabel: UILabel = {
        var label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .caption1)
        return label
    }()

    init(_ place: PlaceInfo, buttonText: String) {
        super.init(frame: .zero)
        setUp(place, buttonText: buttonText)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUp(_ place: PlaceInfo, buttonText: String) {
        nameLabel.text = place.name
        addressLabel.text = place.address

        let placeTag = PlaceTagCapsule(place.tag)

        let placeInfoFirstRow = UIStackView(arrangedSubviews: [nameLabel, placeTag])
        placeInfoFirstRow.axis = .horizontal
        placeInfoFirstRow.spacing = 5
        placeInfoFirstRow.alignment = .center

        let placeInfoStack = UIStackView(arrangedSubviews: [placeInfoFirstRow, addressLabel])
        placeInfoStack.axis = .vertical
        placeInfoStack.spacing = 3
        placeInfoStack.alignment = .leading

        let button = UIButton.filled(
            title: buttonText,
            background: .blue2,
            tint: .white,
            font: .caption1,
            edgeInsets: .init(
                top: 4,
                leading: 10,
                bottom: 4,
                trailing: 10
            )
        )
        let contentStack = UIStackView(arrangedSubviews: [placeInfoStack, button])
        contentStack.axis = .horizontal
        contentStack.alignment = .center
        contentStack.distribution = .equalSpacing

        addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])

        button.addTarget(self, action: #selector(onButtonTapped), for: .touchUpInside)
    }

    @objc private func onButtonTapped() { onButtonTap?() }

}
