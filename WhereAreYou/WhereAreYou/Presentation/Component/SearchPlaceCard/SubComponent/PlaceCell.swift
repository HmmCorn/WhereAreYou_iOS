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

    private let placeTag: PlaceTagCapsule
    private let selectionButton: UIButton

    init(_ place: PlaceInfo, buttonText: String) {
        self.placeTag = PlaceTagCapsule(title: place.tagTitle, color: place.tagColor.uiColor)
        self.selectionButton = UIButton.filled(
            title: buttonText,
            background: .blue2.withAlphaComponent(0.85),
            tint: .white,
            font: .caption1,
            edgeInsets: NSDirectionalEdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10)
        )
        super.init(frame: .zero)
        nameLabel.text = place.name
        addressLabel.text = place.address
        setUpLayout()
        setUpActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init(_:buttonText:)")
    }

    // MARK: - Layout

    private func setUpLayout() {
        let placeInfoFirstRow = UIStackView(arrangedSubviews: [nameLabel, placeTag])
        placeInfoFirstRow.axis = .horizontal
        placeInfoFirstRow.spacing = 5
        placeInfoFirstRow.alignment = .center

        let placeInfoStack = UIStackView(arrangedSubviews: [placeInfoFirstRow, addressLabel])
        placeInfoStack.axis = .vertical
        placeInfoStack.spacing = 3
        placeInfoStack.alignment = .leading

        let contentStack = UIStackView(arrangedSubviews: [placeInfoStack, selectionButton])
        contentStack.axis = .horizontal
        contentStack.alignment = .center
        contentStack.distribution = .equalSpacing
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }

    // MARK: - Actions

    private func setUpActions() {
        selectionButton.addAction(UIAction { [weak self] _ in self?.onButtonTap?() }, for: .touchUpInside)
    }

}
