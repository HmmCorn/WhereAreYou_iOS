//
//  AppointmentCreationViewController.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-24.
//

import UIKit
import Combine

final class AppointmentCreationViewController: UIViewController {

    private let viewModel: AppointmentCreationViewModel
    weak var coordinator: HomeCoordinator?
    private var cancellables = Set<AnyCancellable>()

    private let logoImage: UIImageView = {
        let imageView = UIImageView(image: .logo)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let creationCard = AppointmentCreateCard()

    private var confirmCard: AppointmentConfirmCard?

    init(_ viewModel: AppointmentCreationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .pointBackground
        title = "약속 생성"
        setUpLayout()
        setUpActions()
        bindViewModel()
    }

    private func setUpLayout() {
        logoImage.translatesAutoresizingMaskIntoConstraints = false
        creationCard.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(logoImage)
        view.addSubview(creationCard)

        NSLayoutConstraint.activate([
            logoImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            logoImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logoImage.widthAnchor.constraint(equalToConstant: 77),
            logoImage.heightAnchor.constraint(equalToConstant: 48),

            creationCard.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -50),
            creationCard.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 45),
            creationCard.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -45),
        ])
    }

    private func setUpActions() {
        creationCard.onNameChanged = { [weak self] new in
            self?.viewModel.setTitle(new)
        }
        creationCard.onDateRowTap = { [weak self] in
            self?.presentDatePicker()
        }
        creationCard.onPlaceRowTap = { [weak self] in
            self?.presentPlaceSearch()
        }
        creationCard.onMapButtonTap = { [weak self] in
            self?.presentPlaceMapSelection()
        }
        creationCard.onCreateTap = { [weak self] in
            self?.viewModel.create()
        }
    }

    private func bindViewModel() {
        viewModel.$appointmentDate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] date in
                guard let self, let date else { return }
                self.creationCard.setDateLabel(date)
            }
            .store(in: &cancellables)

        viewModel.$place
            .receive(on: DispatchQueue.main)
            .sink { [weak self] placeInfo in
                guard let self, let placeInfo else { return }
                self.creationCard.setPlaceLabel(name: placeInfo.name)
            }
            .store(in: &cancellables)

        viewModel.$hasCreated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hasCreated in
                guard let self, hasCreated else { return }
                self.showConfirmCard()
            }
            .store(in: &cancellables)
    }

}


extension AppointmentCreationViewController {

    // MARK: - Confirm Card Transition

    private func showConfirmCard() {
        let info = viewModel.makeAppointmentInfo()
        let card = AppointmentConfirmCard(data: info)
        self.confirmCard = card

        card.onCopyCodeTap = {
            UIPasteboard.general.string = info.code
        }
        card.onConfirmTap = { [weak self] in
            guard let self else { return }
            self.coordinator?.replaceAppointmentCreation(self, withChatFor: info)
        }

        view.addSubview(card)
        NSLayoutConstraint.activate([
            card.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -50),
            card.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 45),
            card.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -45),
        ])

        card.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
        card.alpha = 0

        UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5) {
            self.creationCard.transform = CGAffineTransform(translationX: -self.view.bounds.width, y: 0)
            self.creationCard.alpha = 0
            card.transform = .identity
            card.alpha = 1
        }
    }

    // MARK: - Date Picker

    private func presentDatePicker() {
        let pickerViewController = DatePickerSheetViewController(
            title: "약속 날짜/시간 설정",
            initialDate: viewModel.appointmentDate
        )
        pickerViewController.onDateSelected = { [weak self] date in
            self?.viewModel.setDate(date)
        }

        if let sheet = pickerViewController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }

        present(pickerViewController, animated: true)
    }


    // MARK: - Search Place Card

    private func presentPlaceSearch() {
        let searchPlaceViewController = coordinator?.showPlaceSearch(
            selectionButtonTitle: "선택하기",
            style: .onlyHeader(title: "약속 장소 검색")
        )
        searchPlaceViewController?.onPlaceSelected = { [weak self, weak searchPlaceViewController] place in
            self?.viewModel.setPlace(place)
            searchPlaceViewController?.dismiss(animated: true)
        }
    }

    // MARK: - Place Map Selection

    private func presentPlaceMapSelection() {
        coordinator?.showPlaceMapSelection(
            initialCoordinate: viewModel.place?.coordinate
        ) { [weak self] place in
            self?.viewModel.setPlace(place)
        }
    }

}
