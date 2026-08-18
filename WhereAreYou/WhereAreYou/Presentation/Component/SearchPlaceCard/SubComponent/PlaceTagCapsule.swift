//
//  PlaceTagCapsule.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-16.
//

import UIKit

final class PlaceTagCapsule: UIView {

    private let label: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption2)
        label.textColor = .white
        return label
    }()

    init(title: String, color: UIColor) {
        super.init(frame: .zero)
        label.text = title
        setUp(backgroundColor: color)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init(_:)")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }

    func setColor(_ color: UIColor) {
        backgroundColor = color
    }

    private func setUp(backgroundColor: UIColor) {
        self.backgroundColor = backgroundColor

        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)

        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5)
        ])
    }

}
