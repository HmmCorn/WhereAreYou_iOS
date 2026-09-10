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
    weak var coordinator: AppointmentRouteCoordinating?
    private var cancellables = Set<AnyCancellable>()

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
        label.text = "참여자 이동 경로"
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

    // MARK: - Info

    private let infoView = AppointmentRouteInfoView(frame: .zero)

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
        infoView.onChangeRouteTap = { [weak self] in self?.viewModel.changeRouteTapped() }
        viewModel.onChangeRouteTap = { [weak self] destination in
            self?.presentRouteSearch(destination: destination)
        }

        viewModel.$placeName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                self?.subtitleLabel.text = name.map { "목적지: \($0)" }
                self?.infoView.setPlaceName(name)
            }
            .store(in: &cancellables)

        viewModel.$placeCoordinate
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] coordinate in
                guard let self else { return }
                self.mapView.setPlaceMarker(coordinate: coordinate, name: self.viewModel.placeName ?? "")
            }
            .store(in: &cancellables)

        viewModel.$participants
            .receive(on: DispatchQueue.main)
            .sink { [weak self] participants in
                self?.mapView.setParticipants(participants)
                self?.infoView.setParticipants(participants)
            }
            .store(in: &cancellables)

        viewModel.$myRouteSummary
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] summary in
                guard let self else { return }
                self.infoView.setDeparture(timeText: summary.departureTimeText, elapsedText: summary.elapsedTimeText)
                self.infoView.setArrival(
                    timeText: summary.arrivalTimeText,
                    remainingText: "\(summary.remainingTimeText) 남음"
                )
                self.infoView.setRemaining(timeText: summary.remainingTimeText)
                self.infoView.setSteps(summary.steps)
            }
            .store(in: &cancellables)
    }

    // MARK: - Route Search

    private func presentRouteSearch(destination: Place?) {
        coordinator?.showRouteSearch(from: self, destination: destination)
    }

    // MARK: - Action

    private func closeTapped() {
        presentingViewController?.dismiss(animated: true)
    }

    // MARK: - Layout

    private func setUpLayout() {
        [titleLabel, subtitleLabel, closeButton, mapView, infoView].forEach {
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

            infoView.topAnchor.constraint(equalTo: mapView.bottomAnchor),
            infoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            infoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            infoView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            infoView.heightAnchor.constraint(equalTo: mapView.heightAnchor, multiplier: 5.5 / 4.5),
        ])
    }

}
