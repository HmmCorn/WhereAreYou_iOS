//
//  RouteCard.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-22.
//

import UIKit

final class RouteCard: UIView {

    var onTap: (() -> Void)?

    private let route: Route
    private let isSelected: Bool

    init(route: Route, isSelected: Bool) {
        self.route = route
        self.isSelected = isSelected
        super.init(frame: .zero)
        setUp()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUp() {
        backgroundColor = .white
        layer.cornerRadius = 12

        let mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.spacing = 12

        mainStack.addArrangedSubview(makeHeaderRow())

        for step in route.step {
            mainStack.addArrangedSubview(makeStepView(step))
        }

        let radioView = makeRadioView()

        mainStack.translatesAutoresizingMaskIntoConstraints = false
        radioView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)
        addSubview(radioView)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),

            radioView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            radioView.centerYAnchor.constraint(equalTo: centerYAnchor),
            radioView.widthAnchor.constraint(equalToConstant: 24),
            radioView.heightAnchor.constraint(equalToConstant: 24),
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tapGesture)
    }

    @objc private func tapped() { onTap?() }

    // MARK: - Header

    private func makeHeaderRow() -> UIView {
        let durationLabel = UILabel()
        durationLabel.text = formatDuration(route.arrivalTime.timeIntervalSince(route.departureTime) / 60)
        durationLabel.font = .boldPreferredFont(forTextStyle: .headline)

        let timeRangeLabel = UILabel()
        let depStr = route.departureTime.koreanTimeString
        let arrStr = route.arrivalTime.koreanTimeString
        timeRangeLabel.text = "\(depStr) - \(arrStr)"
        timeRangeLabel.font = .preferredFont(forTextStyle: .footnote)
        timeRangeLabel.textColor = .secondaryLabel

        let stack = UIStackView(arrangedSubviews: [durationLabel, timeRangeLabel])
        stack.axis = .vertical
        stack.spacing = 2
        return stack
    }

    // MARK: - Step

    private func makeStepView(_ step: RouteStep) -> UIView {
        let container = UIView()

        let icon = UIImageView(image: UIImage(systemName: step.transportType.icon))
        icon.tintColor = step.transportType.color
        icon.contentMode = .scaleAspectFit

        let nameLabel = UILabel()
        nameLabel.text = "\(step.departurePoint.name) > \(step.destination.name)"
        nameLabel.font = .boldPreferredFont(forTextStyle: .subheadline)

        let durationLabel = UILabel()
        durationLabel.text = formatDuration(step.estimatedTime)
        durationLabel.font = .preferredFont(forTextStyle: .footnote)
        durationLabel.textColor = .secondaryLabel

        let iconSize: CGFloat = 16
        icon.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(icon)
        container.addSubview(nameLabel)
        container.addSubview(durationLabel)

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            icon.topAnchor.constraint(equalTo: container.topAnchor, constant: 2),
            icon.widthAnchor.constraint(equalToConstant: iconSize),
            icon.heightAnchor.constraint(equalToConstant: iconSize),

            nameLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 6),
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor),

            durationLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            durationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            durationLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        return container
    }

    // MARK: - Radio

    private func makeRadioView() -> UIView {
        let outer = UIView()
        outer.layer.cornerRadius = 12
        outer.layer.borderWidth = 2
        outer.layer.borderColor = isSelected ? UIColor.blue1.cgColor : UIColor.separator.cgColor

        if isSelected {
            let inner = UIView()
            inner.backgroundColor = .blue1
            inner.layer.cornerRadius = 7
            inner.translatesAutoresizingMaskIntoConstraints = false
            outer.addSubview(inner)
            NSLayoutConstraint.activate([
                inner.centerXAnchor.constraint(equalTo: outer.centerXAnchor),
                inner.centerYAnchor.constraint(equalTo: outer.centerYAnchor),
                inner.widthAnchor.constraint(equalToConstant: 14),
                inner.heightAnchor.constraint(equalToConstant: 14),
            ])
        }

        return outer
    }

    // MARK: - Formatting

    private func formatDuration(_ minutes: Double) -> String {
        let total = Int(minutes)
        let hours = total / 60
        let mins = total % 60
        if hours > 0 {
            return mins > 0 ? "\(hours)시간 \(mins)분" : "\(hours)시간"
        }
        return "\(mins)분"
    }

}
