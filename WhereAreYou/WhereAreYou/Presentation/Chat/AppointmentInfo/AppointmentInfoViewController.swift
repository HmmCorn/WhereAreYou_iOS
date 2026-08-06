//
//  AppointmentInfoViewController.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-06.
//

import UIKit
import Combine

final class AppointmentInfoViewController: UIViewController {

    private let viewModel: AppointmentInfoViewModel
    private var cancellables = Set<AnyCancellable>()
    private var card: AppointmentInfoCard?

    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.alpha = 0
        return view
    }()

    init(viewModel: AppointmentInfoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setUpLayout()
        bindViewModel()
        viewModel.fetchAppointmentInfo()
    }

    private func setUpLayout() {
        dimView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimView)
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimTapped))
        dimView.addGestureRecognizer(tapGesture)
    }

    @objc private func dimTapped() {
        dismissCard()
    }

    private func bindViewModel() {
        viewModel.$appointmentInfo
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] info in
                self?.showCard(with: info)
            }
            .store(in: &cancellables)
    }

    private func showCard(with info: AppointmentInfo) {
        card?.removeFromSuperview()

        let infoCard = AppointmentInfoCard(data: info)
        infoCard.alpha = 0
        infoCard.transform = CGAffineTransform(translationX: 0, y: 20)
        view.addSubview(infoCard)
        NSLayoutConstraint.activate([
            infoCard.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            infoCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])

        infoCard.onClose = { [weak self] in self?.dismissCard() }
        infoCard.onNameEditingEnded = { [weak self] name in self?.viewModel.updateNameIfChanged(name) }
        infoCard.onDateRowTap = { [weak self] in self?.presentDatePicker() }
        infoCard.onPlaceRowTap = { [weak self] in self?.presentPlaceSearch() }
        infoCard.onMapButtonTap = { [weak self] in self?.presentPlaceMapSelection() }
        infoCard.onCopyCodeTap = { UIPasteboard.general.string = info.code }

        card = infoCard

        UIView.animate(withDuration: 0.25) {
            self.dimView.alpha = 1
            infoCard.alpha = 1
            infoCard.transform = .identity
        }
    }

    private func dismissCard() {
        UIView.animate(withDuration: 0.2, animations: {
            self.dimView.alpha = 0
            self.card?.alpha = 0
            self.card?.transform = CGAffineTransform(translationX: 0, y: 20)
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    // MARK: - Date Picker

    private func presentDatePicker() {
        let pickerViewController = DatePickerSheetViewController(
            title: "약속 날짜/시간 설정",
            initialDate: viewModel.appointmentInfo?.date
        )
        pickerViewController.onDateSelected = { [weak self] date in
            self?.viewModel.updateDate(date)
        }

        if let sheet = pickerViewController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        present(pickerViewController, animated: true)
    }

    // MARK: - Place Search

    private func presentPlaceSearch() {
        let searchPlaceViewController = SearchPlaceCardViewController(
            viewModel: SearchPlaceCardViewModel(
                searchPlacesUseCase: SearchPlacesUseCase(
                    repository: MockPlaceSearchRepository()
                )
            ),
            selectionButtonTitle: "선택하기",
            style: .onlyHeader(title: "약속 장소 검색")
        )

        searchPlaceViewController.onPlaceSelected = { [weak self] place in
            self?.viewModel.updatePlace(place)
            searchPlaceViewController.dismiss(animated: true)
        }

        if let sheet = searchPlaceViewController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        present(searchPlaceViewController, animated: true)
    }

    // MARK: - Place Map Selection

    private func presentPlaceMapSelection() {
        let placeSelectionViewModel = PlaceSelectionViewModel(
            getCurrentLocationUseCase: GetCurrentLocationUseCase(
                repository: CoreLocationRepository()
            ),
            getNearbyPlaceUseCase: GetNearbyPlaceUseCase(
                nearbyPlaceRepository: MockNearbyPlaceRepository(),
                reverseGeocodingRepository: MockReverseGeocodingRepository()
            ),
            initialCoordinate: viewModel.appointmentInfo?.location?.coordinate
        )
        let placeSelectionViewController = PlaceSelectionViewController(viewModel: placeSelectionViewModel)

        placeSelectionViewController.onPlaceConfirmed = { [weak self] place in
            self?.viewModel.updatePlace(place)
        }

        let navigationController = UINavigationController(rootViewController: placeSelectionViewController)
        navigationController.isModalInPresentation = true

        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.large()]
        }
        present(navigationController, animated: true)
    }

}
