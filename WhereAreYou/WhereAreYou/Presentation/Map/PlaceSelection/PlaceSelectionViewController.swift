//
//  PlaceSelectionViewController.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/27/26.
//

import UIKit
import Combine

final class PlaceSelectionViewController: UIViewController {

    var onPlaceConfirmed: ((Place) -> Void)?

    private var isInitialCameraMoveHandled = false

    private let viewModel: PlaceSelectionViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: PlaceSelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Header

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "장소 선택"
        label.font = .preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "지도를 움직여 장소를 선택해주세요"
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

    private let naverMapView = PlaceSelectionMapView(frame: .zero)

    // MARK: - Bottom Card

    private let bottomCard: UIView = {
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
        label.font = .boldPreferredFont(forTextStyle: .callout)
        label.textColor = .label
        return label
    }()

    private let placeAddressLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        return label
    }()

    private let placeDistanceLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var searchOtherPlaceButton: UIButton = {
        var config = UIButton.Configuration.filled()

        var attributedTitle = AttributedString("다른 장소 검색")
        attributedTitle.font = .preferredFont(forTextStyle: .footnote)
        config.attributedTitle = attributedTitle

        config.image = UIImage(systemName: "magnifyingglass")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(
            font: .preferredFont(forTextStyle: .footnote)
        )
        config.imagePlacement = .leading
        config.imagePadding = 8

        config.baseBackgroundColor = UIColor.blue2.withAlphaComponent(0.2)
        config.baseForegroundColor = .black
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 18)
        config.cornerStyle = .fixed
        config.background.cornerRadius = 12

        let button = UIButton(configuration: config)
        button.contentHorizontalAlignment = .leading

        let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowImageView.tintColor = .black
        arrowImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(
            font: .preferredFont(forTextStyle: .footnote)
        )
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(arrowImageView)

        NSLayoutConstraint.activate([
            arrowImageView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -18),
            arrowImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            button.heightAnchor.constraint(equalToConstant: 37),
        ])

        return button
    }()

    private lazy var confirmButton: UIButton = {
        let button = UIButton.filled(
            title: "확인", background: .blue2, tint: .white, font: .callout
        )
        button.configuration?.cornerStyle = .fixed
        button.configuration?.background.cornerRadius = 12
        button.heightAnchor.constraint(equalToConstant: 37).isActive = true
        button.addAction(UIAction { [weak self] _ in self?.confirmTapped() }, for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpLayout()
        naverMapView.onCameraIdle = { [weak self] coordinate in
            self?.viewModel.setCenterCoordinate(coordinate)
        }
        searchOtherPlaceButton.addAction(
            UIAction { [weak self] _ in self?.searchOtherPlaceTapped() },
            for: .touchUpInside
        )
        bindViewModel()
        if let initialCoordinate = viewModel.initialCoordinate {
            isInitialCameraMoveHandled = true
            naverMapView.moveCamera(to: initialCoordinate)
            viewModel.setCenterCoordinate(initialCoordinate)
        }
        viewModel.fetchCurrentLocation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - ViewModel Binding

    private func bindViewModel() {
        viewModel.$currentLocation
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] coordinate in
                guard let self, !self.isInitialCameraMoveHandled else { return }
                self.isInitialCameraMoveHandled = true
                self.naverMapView.moveCamera(to: coordinate)
            }
            .store(in: &cancellables)

        viewModel.$isFetchingNearbyPlace
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFetching in
                guard let self else { return }
                if isFetching {
                    self.placeNameLabel.text = "장소를 찾는 중..."
                    self.placeAddressLabel.text = " "
                    self.placeDistanceLabel.text = " "
                }
            }
            .store(in: &cancellables)

        viewModel.$nearbyPlace
            .receive(on: DispatchQueue.main)
            .sink { [weak self] place in
                self?.placeNameLabel.text = place?.name ?? "장소를 불러오지 못했습니다"
                self?.placeAddressLabel.text = place?.address ?? " "
            }
            .store(in: &cancellables)

        viewModel.$distanceText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                self?.placeDistanceLabel.text = text
            }
            .store(in: &cancellables)

        viewModel.$isFetchingNearbyPlace
            .combineLatest(viewModel.$nearbyPlace)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFetching, place in
                self?.confirmButton.isEnabled = !isFetching && place != nil
            }
            .store(in: &cancellables)
    }

    // MARK: - Action

    private func closeTapped() {
        presentingViewController?.dismiss(animated: true)
    }

    private func confirmTapped() {
        guard let place = viewModel.nearbyPlaceDomain else { return }
        onPlaceConfirmed?(place)
        presentingViewController?.dismiss(animated: true)
    }

    private func searchOtherPlaceTapped() {
        let searchPlaceViewController = SearchPlaceCardViewController(
            viewModel: SearchPlaceCardViewModel(
                searchPlacesUseCase: SearchPlacesUseCase(
                    repository: MockPlaceSearchRepository()
                )
            ),
            selectionButtonTitle: "선택하기",
            style: .onlyHeader(title: "장소 검색")
        )
        searchPlaceViewController.onPlaceSelected = { [weak self] place in
            self?.navigationController?.popViewController(animated: true)
            self?.naverMapView.moveCamera(to: place.coordinate)
        }
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.pushViewController(searchPlaceViewController, animated: true)
    }

    // MARK: - Layout

    private func setUpLayout() {
        [titleLabel, subtitleLabel, closeButton, naverMapView].forEach {
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

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            naverMapView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12),
            naverMapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            naverMapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        setUpBottomCard()
    }

    private func setUpBottomCard() {
        bottomCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomCard)

        NSLayoutConstraint.activate([
            naverMapView.bottomAnchor.constraint(equalTo: bottomCard.topAnchor),

            bottomCard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomCard.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomCard.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let infoStack = UIStackView(arrangedSubviews: [placeNameLabel, placeAddressLabel, placeDistanceLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 5

        let buttonStack = UIStackView(arrangedSubviews: [searchOtherPlaceButton, confirmButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 9
        buttonStack.distribution = .fill

        let contentStack = UIStackView(arrangedSubviews: [infoStack, buttonStack])
        contentStack.axis = .vertical
        contentStack.spacing = 17
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        bottomCard.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: bottomCard.topAnchor, constant: 27),
            contentStack.leadingAnchor.constraint(equalTo: bottomCard.leadingAnchor, constant: 31),
            contentStack.trailingAnchor.constraint(equalTo: bottomCard.trailingAnchor, constant: -31),
            contentStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }

}
