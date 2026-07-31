//
//  AppointmentRouteViewController.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/31/26.
//

import UIKit
import Combine

final class AppointmentRouteViewController: UIViewController {

    private let viewModel: AppointmentRouteViewModel
    private var cancellables = Set<AnyCancellable>()
    private var isInitialCameraMoveHandled = false

    init(viewModel: AppointmentRouteViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Header

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "참여자 위치"
        label.font = .preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private lazy var closeButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "xmark")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(
            pointSize: 17, weight: .medium
        )
        config.baseForegroundColor = .secondaryLabel
        config.background.backgroundColor = .secondarySystemFill
        config.background.cornerRadius = 22
        config.cornerStyle = .fixed

        let button = UIButton(configuration: config)
        button.addAction(UIAction { [weak self] _ in self?.closeTapped() }, for: .touchUpInside)
        return button
    }()

    // MARK: - Map

    private let mapView = AppointmentRouteMapView(frame: .zero)

    // MARK: - Info Area

    private let infoContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: -4)
        return view
    }()

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
        button.addAction(UIAction { [weak self] _ in self?.viewModel.changeRouteTapped() }, for: .touchUpInside)
        return button
    }()

    private let departureTimeSummary = SummaryColumnView(title: "출발 시간")
    private let arrivalTimeSummary = SummaryColumnView(title: "도착 예정", subText: "예정")
    private let remainingTimeSummary = SummaryColumnView(title: "남은 시간", subText: "남음")

    private let stepsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()

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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpLayout()
        bindViewModel()
        viewModel.fetchAppointmentDetail()
    }

    // MARK: - ViewModel Binding

    private func bindViewModel() {
        viewModel.$placeName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                self?.subtitleLabel.text = name.map { "목적지: \($0)" }
                self?.placeNameLabel.text = name
            }
            .store(in: &cancellables)

        viewModel.$placeCoordinate
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] coordinate in
                guard let self else { return }
                self.mapView.setPlaceMarker(coordinate: coordinate, name: self.viewModel.placeName ?? "")
                if !self.isInitialCameraMoveHandled {
                    self.isInitialCameraMoveHandled = true
                    self.mapView.moveCamera(to: coordinate)
                }
            }
            .store(in: &cancellables)

        viewModel.$participants
            .receive(on: DispatchQueue.main)
            .sink { [weak self] participants in
                self?.mapView.setParticipants(participants)
            }
            .store(in: &cancellables)

        viewModel.$myDepartureTimeText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in self?.departureTimeSummary.valueLabel.text = text }
            .store(in: &cancellables)

        viewModel.$myElapsedTimeText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in self?.departureTimeSummary.subLabel.text = text }
            .store(in: &cancellables)

        viewModel.$myArrivalTimeText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in self?.arrivalTimeSummary.valueLabel.text = text }
            .store(in: &cancellables)

        viewModel.$myRemainingTimeText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in self?.remainingTimeSummary.valueLabel.text = text }
            .store(in: &cancellables)

        viewModel.$mySteps
            .receive(on: DispatchQueue.main)
            .sink { [weak self] steps in self?.updateSteps(steps) }
            .store(in: &cancellables)

        viewModel.$participants
            .receive(on: DispatchQueue.main)
            .sink { [weak self] participants in self?.updateParticipantRows(participants) }
            .store(in: &cancellables)
    }

    // MARK: - Action

    private func closeTapped() {
        presentingViewController?.dismiss(animated: true)
    }

    // MARK: - Info Content Update

    private func updateSteps(_ steps: [RouteStep]) {
        stepsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for step in steps {
            let icon = UIImageView(image: UIImage(systemName: step.transportType.icon))
            icon.tintColor = step.transportType.color
            icon.contentMode = .scaleAspectFit
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.widthAnchor.constraint(equalToConstant: 14).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 14).isActive = true

            let label = UILabel()
            label.text = "\(Int(step.estimatedTime))분"
            label.font = .preferredFont(forTextStyle: .caption1)
            label.textColor = .secondaryLabel

            let stepStack = UIStackView(arrangedSubviews: [icon, label])
            stepStack.axis = .horizontal
            stepStack.spacing = 4
            stepStack.alignment = .center

            stepsStack.addArrangedSubview(stepStack)
        }
    }

    private func updateParticipantRows(_ participants: [AppointmentRouteParticipant]) {
        participantsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let colors = UIColor.participantColors(count: participants.count)
        for (index, participant) in participants.enumerated() where !participant.isMe {
            participantsStack.addArrangedSubview(ParticipantRouteRow(participant: participant, color: colors[index]))
        }
    }

    // MARK: - Layout

    private func setUpLayout() {
        [titleLabel, subtitleLabel, closeButton, mapView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            mapView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        setUpInfoContainer()
    }

    private func setUpInfoContainer() {
        infoContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoContainer)

        NSLayoutConstraint.activate([
            infoContainer.topAnchor.constraint(equalTo: mapView.bottomAnchor),
            infoContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            infoContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            infoContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            infoContainer.heightAnchor.constraint(equalTo: mapView.heightAnchor, multiplier: 5.5 / 4.5),
        ])

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
            destinationRow, horizontalDivider, summaryRow, stepsStack, participantsScrollView,
        ])
        contentStack.axis = .vertical
        contentStack.spacing = 10
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        infoContainer.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: infoContainer.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: infoContainer.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: infoContainer.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
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
        stack.spacing = 4
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
