//
//  FilterTagBox.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-16.
//

import UIKit

final class FilterTagBox: UIView {

    var onFilterTap: ((PlaceType) -> Void)?
    var onResetTap: (() -> Void)?

    private let headerLabel: UILabel = {
        var label = UILabel()
        label.text = "검색 필터"
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .caption1)
        return label
    }()

    private var resetButton: UIButton = {
        var configuration = UIButton.Configuration.filled()

        var title = AttributedString("필터 초기화")
        title.font = .preferredFont(forTextStyle: .caption2)
        title.foregroundColor = .secondaryLabel

        configuration.baseBackgroundColor = .white
        configuration.attributedTitle = title
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 5, bottom: 3, trailing: 5)

        let button = UIButton(configuration: configuration)

        button.layer.cornerRadius = 5
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 8
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.masksToBounds = false

        return button
    }()

    private let filters: [PlaceType: FilterCapsule] = Dictionary(
        uniqueKeysWithValues: PlaceType.allCases.map { ($0, FilterCapsule(placeType: $0)) }
    )

    private let filterStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 5
        stack.alignment = .leading
        return stack
    }()

    init() {
        super.init(frame: .zero)
        setUp()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init()")
    }

    func configure(selected: Set<PlaceType>) {
        var selectedTypes: [PlaceType] = []
        var unselectedTypes: [PlaceType] = []
        selectedTypes.reserveCapacity(selected.count)
        unselectedTypes.reserveCapacity(PlaceType.allCases.count - selected.count)

        for placeType in PlaceType.allCases {
            if selected.contains(placeType) {
                selectedTypes.append(placeType)
            } else {
                unselectedTypes.append(placeType)
            }
        }

        selectedTypes.append(contentsOf: unselectedTypes)

        UIView.animate(withDuration: 0.2) {
            self.filterStack.arrangedSubviews.forEach { self.filterStack.removeArrangedSubview($0) }
            for placeType in selectedTypes {
                guard let capsule = self.filters[placeType] else { continue }
                capsule.isSelected = selected.contains(placeType)
                self.filterStack.addArrangedSubview(capsule)
            }
            self.layoutIfNeeded()
        }
    }

    private func setUp() {
        let header = UIStackView(arrangedSubviews: [headerLabel, resetButton])
        header.axis = .horizontal
        header.distribution = .equalSpacing
        header.alignment = .top

        header.translatesAutoresizingMaskIntoConstraints = false
        filterStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(header)
        addSubview(filterStack)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: topAnchor),
            header.leadingAnchor.constraint(equalTo: leadingAnchor),
            header.trailingAnchor.constraint(equalTo: trailingAnchor),

            filterStack.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 10),
            filterStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            filterStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        filters.values.forEach { capsule in
            capsule.addTarget(self, action: #selector(filterTapped(_:)), for: .touchUpInside)
        }
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
    }

    @objc private func filterTapped(_ sender: FilterCapsule) {
        onFilterTap?(sender.placeType)
    }

    @objc private func resetTapped() {
        onResetTap?()
    }

}

// MARK: - Sub-component

extension FilterTagBox {

    final class FilterCapsule: UIButton {

        let placeType: PlaceType

        override var isSelected: Bool {
            didSet { updateAppearance() }
        }

        override var isHighlighted: Bool {
            didSet { updateAppearance() }
        }

        init(placeType: PlaceType) {
            self.placeType = placeType
            super.init(frame: .zero)
            setUp()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented — use init(placeType:)")
        }

        private func setUp() {
            var configuration = UIButton.Configuration.filled()

            var title = AttributedString(placeType.title)
            title.font = .preferredFont(forTextStyle: .caption2)
            title.foregroundColor = .white

            configuration.attributedTitle = title
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5)

            self.configuration = configuration
            setContentHuggingPriority(.required, for: .horizontal)
            setContentCompressionResistancePriority(.required, for: .horizontal)

            updateAppearance()
        }

        private func updateAppearance() {
            let baseColor: UIColor = isSelected
                ? placeType.color
                : UIColor.systemGray2.withAlphaComponent(0.3)
            configuration?.background.backgroundColor = isHighlighted ? baseColor.withAlphaComponent(0.6) : baseColor
        }

    }

}
