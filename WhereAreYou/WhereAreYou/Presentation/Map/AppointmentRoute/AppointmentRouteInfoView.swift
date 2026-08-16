//
//  AppointmentRouteInfoView.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/31/26.
//

import UIKit

/// 약속 경로 화면의 info 영역을 담당하는 뷰
final class AppointmentRouteInfoView: UIView {

    var onChangeRouteTap: (() -> Void)? {
        get { routeSummaryCard.onChangeRouteTap }
        set { routeSummaryCard.onChangeRouteTap = newValue }
    }

    private let routeSummaryCard = RouteSummaryCardView()

    private let participantsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        return stack
    }()

    private let participantsScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: -4)
        setUpLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    func setPlaceName(_ name: String?) {
        routeSummaryCard.setPlaceName(name)
    }

    func setDeparture(timeText: String?, elapsedText: String?) {
        routeSummaryCard.setDeparture(timeText: timeText, elapsedText: elapsedText)
    }

    func setArrival(timeText: String?, remainingText: String?) {
        routeSummaryCard.setArrival(timeText: timeText, remainingText: remainingText)
    }

    func setRemaining(timeText: String?) {
        routeSummaryCard.setRemaining(timeText: timeText)
    }

    func setSteps(_ steps: [RouteStepItem]) {
        routeSummaryCard.setSteps(steps)
    }

    func setParticipants(_ participants: [AppointmentRouteParticipant]) {
        participantsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let others = participants.filter { !$0.isMe }
        for (index, participant) in others.enumerated() {
            if index > 0 {
                let divider = Self.makeHorizontalDivider()
                participantsStack.addArrangedSubview(divider)
                participantsStack.setCustomSpacing(8, after: divider)
            }
            let row = ParticipantRouteRow(participant: participant)
            participantsStack.addArrangedSubview(row)
            participantsStack.setCustomSpacing(6, after: row)
        }
    }

    // MARK: - Layout

    private func setUpLayout() {
        participantsScrollView.addSubview(participantsStack)
        participantsStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            participantsStack.topAnchor.constraint(equalTo: participantsScrollView.topAnchor),
            participantsStack.leadingAnchor.constraint(equalTo: participantsScrollView.leadingAnchor),
            participantsStack.trailingAnchor.constraint(equalTo: participantsScrollView.trailingAnchor),
            participantsStack.bottomAnchor.constraint(equalTo: participantsScrollView.bottomAnchor),
            participantsStack.widthAnchor.constraint(equalTo: participantsScrollView.widthAnchor),
        ])

        let contentStack = UIStackView(arrangedSubviews: [
            routeSummaryCard, participantsScrollView,
        ])
        contentStack.axis = .vertical
        contentStack.spacing = 10
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
    }

    private static func makeHorizontalDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = .separator
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return divider
    }

}

/// 목적지/경로변경/요약/소요시간 바를 담은 카드
private final class RouteSummaryCardView: UIView {

    var onChangeRouteTap: (() -> Void)?

    private let placeNameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldPreferredFont(forTextStyle: .caption1)
        return label
    }()

    private let placeIconImageView: UIImageView = {
        let imageView = UIImageView(image: .pin)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 18).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 18).isActive = true
        return imageView
    }()

    private lazy var changeRouteButton: UIButton = {
        let button = UIButton.filled(
            title: "경로 변경",
            background: UIColor.blue1,
            tint: .white,
            font: .caption2,
            edgeInsets: NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        )
        button.addAction(UIAction { [weak self] _ in self?.onChangeRouteTap?() }, for: .touchUpInside)
        return button
    }()

    private let departureTimeSummary = SummaryColumnView(title: "출발 시간")
    private let arrivalTimeSummary = SummaryColumnView(title: "도착 예정")
    private let remainingTimeSummary = SummaryColumnView(title: "남은 시간")

    private let stepLabelsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()

    private let stepBarsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fill
        return stack
    }()

    private lazy var stepsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [stepLabelsStack, stepBarsStack])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()

    private var stepBarWidthConstraints: [NSLayoutConstraint] = []
    private var stepMinWidths: [CGFloat] = []
    private var stepRatios: [CGFloat] = []
    private var lastLaidOutStepBarsWidth: CGFloat = -1

    init() {
        super.init(frame: .zero)
        backgroundColor = .systemBackground
        layer.cornerRadius = 14
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 0, height: 4)
        setUpLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layOutStepBarsIfNeeded()
    }

    // MARK: - Public

    func setPlaceName(_ name: String?) {
        placeNameLabel.text = name
    }

    func setDeparture(timeText: String?, elapsedText: String?) {
        departureTimeSummary.valueLabel.text = timeText
        departureTimeSummary.subLabel.text = elapsedText
    }

    func setArrival(timeText: String?, remainingText: String?) {
        arrivalTimeSummary.valueLabel.text = timeText
        arrivalTimeSummary.subLabel.text = remainingText
    }

    func setRemaining(timeText: String?) {
        remainingTimeSummary.valueLabel.text = timeText
    }

    func setSteps(_ steps: [RouteStepItem]) {
        stepLabelsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stepBarsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stepBarWidthConstraints.forEach { $0.isActive = false }
        stepBarWidthConstraints = []
        stepMinWidths = []
        stepRatios = []
        lastLaidOutStepBarsWidth = -1

        guard !steps.isEmpty else { return }

        let totalTime = max(steps.reduce(0) { $0 + $1.estimatedTimeMinutes }, 1)

        for step in steps {
            let icon = UIImageView(image: UIImage(systemName: step.transportIcon))
            icon.tintColor = step.transportColor
            icon.contentMode = .scaleAspectFit
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.widthAnchor.constraint(equalToConstant: 14).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 14).isActive = true

            let label = UILabel()
            label.text = "\(Int(step.estimatedTimeMinutes))분"
            label.font = .preferredFont(forTextStyle: .caption2)
            label.textColor = .secondaryLabel

            let labelStack = UIStackView(arrangedSubviews: [icon, label])
            labelStack.axis = .horizontal
            labelStack.spacing = 4
            labelStack.alignment = .center
            stepLabelsStack.addArrangedSubview(labelStack)

            let bar = UIView()
            bar.backgroundColor = step.transportColor
            bar.layer.cornerRadius = 2
            bar.heightAnchor.constraint(equalToConstant: 4).isActive = true
            stepBarsStack.addArrangedSubview(bar)

            let widthConstraint = bar.widthAnchor.constraint(equalToConstant: 0)
            widthConstraint.isActive = true
            stepBarWidthConstraints.append(widthConstraint)

            labelStack.widthAnchor.constraint(equalTo: bar.widthAnchor).isActive = true

            let minWidth = labelStack.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).width
            stepMinWidths.append(minWidth)
            stepRatios.append(CGFloat(step.estimatedTimeMinutes / totalTime))
        }

        setNeedsLayout()
    }

    // MARK: - Step Bar Layout

    private func layOutStepBarsIfNeeded() {
        guard !stepMinWidths.isEmpty else { return }

        let availableWidth = stepBarsStack.bounds.width
        guard availableWidth > 0, availableWidth != lastLaidOutStepBarsWidth else { return }
        lastLaidOutStepBarsWidth = availableWidth

        let spacing = stepBarsStack.spacing * CGFloat(stepMinWidths.count - 1)
        let minWidthTotal = stepMinWidths.reduce(0, +)
        let extraSpace = max(availableWidth - spacing - minWidthTotal, 0)

        for (index, minWidth) in stepMinWidths.enumerated() {
            let extra = extraSpace * stepRatios[index]
            stepBarWidthConstraints[index].constant = minWidth + extra
        }
    }

    // MARK: - Layout

    private func setUpLayout() {
        let placeTitleStack = UIStackView(arrangedSubviews: [placeIconImageView, placeNameLabel])
        placeTitleStack.axis = .horizontal
        placeTitleStack.spacing = 6
        placeTitleStack.alignment = .center

        let destinationRow = UIStackView(arrangedSubviews: [placeTitleStack, UIView(), changeRouteButton])
        destinationRow.axis = .horizontal
        destinationRow.alignment = .center

        let horizontalDivider = UIView()
        horizontalDivider.backgroundColor = .separator
        horizontalDivider.translatesAutoresizingMaskIntoConstraints = false
        horizontalDivider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let summaryRow = UIStackView(arrangedSubviews: [
            departureTimeSummary, Self.makeVerticalDivider(), arrivalTimeSummary,
            Self.makeVerticalDivider(), remainingTimeSummary,
        ])
        summaryRow.axis = .horizontal
        summaryRow.alignment = .fill

        NSLayoutConstraint.activate([
            arrivalTimeSummary.widthAnchor.constraint(equalTo: departureTimeSummary.widthAnchor),
            remainingTimeSummary.widthAnchor.constraint(equalTo: departureTimeSummary.widthAnchor),
        ])

        let contentStack = UIStackView(arrangedSubviews: [
            destinationRow, horizontalDivider, summaryRow, stepsStack,
        ])
        contentStack.axis = .vertical
        contentStack.spacing = 10
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
        ])
    }

    private static func makeVerticalDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = .separator
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.widthAnchor.constraint(equalToConstant: 1).isActive = true
        return divider
    }

}

/// info 영역 요약 행(출발/도착/남은시간)의 세로 컬럼 한 칸
private final class SummaryColumnView: UIView {

    let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .boldPreferredFont(forTextStyle: .callout)
        label.textAlignment = .center
        return label
    }()

    let subLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption2)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    init(title: String, subText: String? = nil) {
        super.init(frame: .zero)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .caption1)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center

        subLabel.text = subText

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel, subLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
