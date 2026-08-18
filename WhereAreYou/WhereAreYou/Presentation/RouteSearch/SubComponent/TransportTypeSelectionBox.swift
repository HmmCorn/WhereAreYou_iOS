//
//  TransportTypeSelectionBox.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-22.
//

import UIKit

final class TransportTypeSelectionBox: UIView {

    var onTransportTypeSelected: ((TransportType) -> Void)?

    private var buttons: [(type: TransportType, button: UIButton)] = []
    private(set) var selectedType: TransportType = TransportType.allCases[0]

    init() {
        super.init(frame: .zero)
        setUp()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init()")
    }

    private func setUp() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually

        for type in TransportType.allCases {
            let button = makeButton(for: type)
            buttons.append((type: type, button: button))
            stack.addArrangedSubview(button)

            button.addAction(UIAction { [weak self] _ in
                self?.selectedType = type
                self?.updateButtonStyles()
                self?.onTransportTypeSelected?(type)
            }, for: .touchUpInside)
        }

        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        updateButtonStyles()
    }

    private func makeButton(for type: TransportType) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: type.icon)
        config.title = type.name
        config.imagePlacement = .top
        config.imagePadding = 4
        config.cornerStyle = .fixed
        config.background.cornerRadius = 12
        config.background.strokeWidth = 1.5
        config.background.strokeColor = type.color.uiColor
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 8, bottom: 12, trailing: 8)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = .preferredFont(forTextStyle: .caption1)
            return out
        }
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(
            font: .preferredFont(forTextStyle: .body)
        )
        return UIButton(configuration: config)
    }

    private func updateButtonStyles() {
        for (type, button) in buttons {
            var config = button.configuration ?? .filled()
            if type == selectedType {
                config.baseBackgroundColor = type.color.uiColor.withAlphaComponent(0.8)
                config.baseForegroundColor = .white
            } else {
                config.baseBackgroundColor = .white
                config.baseForegroundColor = type.color.uiColor
            }
            button.configuration = config
        }
    }

}
