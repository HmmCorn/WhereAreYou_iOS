//
//  RouteSearchViewController.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-22.
//

import UIKit
import Combine

final class RouteSearchViewController: UIViewController {

    // MARK: - Spacing

    private static let horizontalPadding: CGFloat = 20
    private static let sectionSpacing: CGFloat = 24
    private static let sectionHeaderBottomSpacing: CGFloat = 12
    private static let bottomButtonHeight: CGFloat = 50
    private static let bottomButtonBottomPadding: CGFloat = 16
    private static let contentTopPadding: CGFloat = 16

    // MARK: - Dependencies

    private let viewModel: RouteSearchViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Section 1: Place input

    private let placeInputView = PlaceInputBox()

    // MARK: - Section 2: Transport type

    private let transportSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "이동 수단 선택"
        label.font = .preferredFont(forTextStyle: .callout)
        label.textColor = .secondaryLabel
        return label
    }()

    private let transportSelector = TransportTypeSelectionBox()

    // MARK: - Section 3: Departure time

    private let timeSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "출발 시간 설정"
        label.font = .preferredFont(forTextStyle: .callout)
        label.textColor = .secondaryLabel
        return label
    }()

    private let timeButton: UIButton = {
        let button = UIButton.filled(
            title: "",
            background: .clear,
            tint: .label,
            font: .footnote,
            edgeInsets: NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
        )
        button.configuration?.background.strokeColor = .separator
        button.configuration?.background.strokeWidth = 1
        return button
    }()

    // MARK: - Section 4: Routes

    private let routeSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "추천 경로"
        label.font = .preferredFont(forTextStyle: .callout)
        label.textColor = .secondaryLabel
        return label
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "출발지와 도착지를 모두 선택해주세요."
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let routeScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    private let routeCardsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()

    // MARK: - Bottom button

    private let selectRouteButton = UIButton.filled(
        title: "이 경로 선택",
        background: .blue1,
        tint: .white,
        font: .body
    )

    // MARK: - Overlay

    private var placeSearchTarget: PlaceSearchTarget = .departure

    private enum PlaceSearchTarget {
        case departure
        case arrival
    }

    // MARK: - Init

    private let initialDeparture: Place?
    private let initialDestination: Place?

    init(viewModel: RouteSearchViewModel, departure: Place? = nil, destination: Place? = nil) {
        self.viewModel = viewModel
        self.initialDeparture = departure
        self.initialDestination = destination
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .pointBackground
        title = "경로 검색"
        setUpLayout()
        setUpActions()
        bindViewModel()
        setUpInitialPlaces()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.setDepartureTime(Date())
    }

    private func setUpInitialPlaces() {
        if let dep = initialDeparture {
            viewModel.setDeparture(dep)
        }
        if let dest = initialDestination {
            viewModel.setDestination(dest)
        }
    }

    // MARK: - Layout

    private func setUpLayout() {

        // 상단 고정 영역: 장소 입력 / 이동 수단 / 출발 시간 / 섹션 헤더들

        let topStack = UIStackView()
        topStack.axis = .vertical
        topStack.translatesAutoresizingMaskIntoConstraints = false

        topStack.isLayoutMarginsRelativeArrangement = true
        topStack.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: Self.contentTopPadding,
            leading: Self.horizontalPadding,
            bottom: 0,
            trailing: Self.horizontalPadding
        )

        let timeSectionRow = makeTimeSectionRow()

        [placeInputView, transportSectionLabel, transportSelector,
         timeSectionRow, routeSectionLabel]
            .forEach { topStack.addArrangedSubview($0) }

        topStack.setCustomSpacing(Self.sectionSpacing, after: placeInputView)
        topStack.setCustomSpacing(Self.sectionHeaderBottomSpacing, after: transportSectionLabel)
        topStack.setCustomSpacing(Self.sectionSpacing, after: transportSelector)
        topStack.setCustomSpacing(Self.sectionHeaderBottomSpacing, after: timeSectionRow)
        topStack.setCustomSpacing(Self.sectionHeaderBottomSpacing, after: routeSectionLabel)

        // 경로 검색 결과 영역: 빈 상태 / 로딩 / 경로 카드 목록

        [routeScrollView, routeCardsStack, selectRouteButton, emptyStateLabel, loadingIndicator]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        routeScrollView.addSubview(routeCardsStack)

        [topStack, emptyStateLabel, loadingIndicator, routeScrollView, selectRouteButton]
            .forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([

            // 상단 고정 영역
            topStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // 빈 상태 라벨 (topStack 바로 아래)
            emptyStateLabel.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: Self.sectionSpacing),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Self.horizontalPadding),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Self.horizontalPadding),

            // 로딩 인디케이터 (topStack 바로 아래)
            loadingIndicator.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: Self.sectionSpacing),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // 경로 카드 스크롤 영역 (topStack ~ 하단 버튼 사이)
            routeScrollView.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: Self.sectionHeaderBottomSpacing),
            routeScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            routeScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            routeScrollView.bottomAnchor.constraint(equalTo: selectRouteButton.topAnchor, constant: -8),

            // 스크롤 내부 카드 스택
            routeCardsStack.topAnchor.constraint(equalTo: routeScrollView.contentLayoutGuide.topAnchor),
            routeCardsStack.leadingAnchor.constraint(equalTo: routeScrollView.contentLayoutGuide.leadingAnchor, constant: Self.horizontalPadding),
            routeCardsStack.trailingAnchor.constraint(equalTo: routeScrollView.contentLayoutGuide.trailingAnchor, constant: -Self.horizontalPadding),
            routeCardsStack.bottomAnchor.constraint(equalTo: routeScrollView.contentLayoutGuide.bottomAnchor, constant: -8),
            routeCardsStack.widthAnchor.constraint(equalTo: routeScrollView.frameLayoutGuide.widthAnchor, constant: -Self.horizontalPadding * 2),

            // 하단 고정 버튼
            selectRouteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Self.horizontalPadding),
            selectRouteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Self.horizontalPadding),
            selectRouteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Self.bottomButtonBottomPadding),
            selectRouteButton.heightAnchor.constraint(equalToConstant: Self.bottomButtonHeight),
        ])

        routeScrollView.isHidden = true
        loadingIndicator.isHidden = true
    }

    private func makeTimeSectionRow() -> UIView {
        let container = UIView()
        timeSectionLabel.translatesAutoresizingMaskIntoConstraints = false
        timeButton.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(timeSectionLabel)
        container.addSubview(timeButton)

        NSLayoutConstraint.activate([
            timeSectionLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            timeSectionLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            timeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            timeButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            timeButton.topAnchor.constraint(equalTo: container.topAnchor),
            timeButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        return container
    }

    // MARK: - Actions

    private func setUpActions() {
        placeInputView.onDepartureTapped = { [weak self] in
            self?.presentPlaceSearch(target: .departure)
        }
        placeInputView.onArrivalTapped = { [weak self] in
            self?.presentPlaceSearch(target: .arrival)
        }
        placeInputView.onCurrentLocationTapped = { [weak self] in
            self?.viewModel.fetchCurrentLocation()
        }
        placeInputView.onDepartureClear = { [weak self] in
            self?.viewModel.setDeparture(nil)
        }
        placeInputView.onArrivalClear = { [weak self] in
            self?.viewModel.setDestination(nil)
        }

        transportSelector.onTransportTypeSelected = { [weak self] type in
            self?.viewModel.setTransportType(type)
        }

        timeButton.addAction(UIAction { [weak self] _ in
            self?.presentTimePicker()
        }, for: .touchUpInside)

        selectRouteButton.addAction(UIAction { _ in
            print("경로 선택 tapped")
        }, for: .touchUpInside)
    }

    // MARK: - ViewModel binding

    private func bindViewModel() {
        viewModel.$departure
            .receive(on: DispatchQueue.main)
            .sink { [weak self] place in
                self?.placeInputView.setDeparture(name: place?.name)
            }
            .store(in: &cancellables)

        viewModel.$destination
            .receive(on: DispatchQueue.main)
            .sink { [weak self] place in
                self?.placeInputView.setArrival(name: place?.name)
            }
            .store(in: &cancellables)

        viewModel.$departureTime
            .receive(on: DispatchQueue.main)
            .sink { [weak self] time in
                guard let self else { return }
                var attr = AttributedString(time.koreanShortDateTimeString)
                attr.font = .preferredFont(forTextStyle: .footnote)
                self.timeButton.configuration?.attributedTitle = attr
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self else { return }
                if isLoading {
                    self.emptyStateLabel.isHidden = true
                    self.routeScrollView.isHidden = true
                    self.loadingIndicator.isHidden = false
                    self.loadingIndicator.startAnimating()
                }
            }
            .store(in: &cancellables)

        Publishers.CombineLatest3(viewModel.$routes, viewModel.$selectedRouteIndex, viewModel.$isLoading)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] routes, selectedIndex, isLoading in
                guard let self, !isLoading else { return }
                self.updateRouteSection(routes: routes, selectedIndex: selectedIndex)
            }
            .store(in: &cancellables)
    }

    // MARK: - Update UI

    private func updateRouteSection(routes: [Route], selectedIndex: Int) {
        routeCardsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let hasPlaces = viewModel.departure != nil && viewModel.destination != nil

        loadingIndicator.isHidden = true
        loadingIndicator.stopAnimating()

        if !hasPlaces {
            emptyStateLabel.isHidden = false
            routeScrollView.isHidden = true
            return
        }

        emptyStateLabel.isHidden = true

        if routes.isEmpty {
            // TODO: 길찾기 API 확인 후 대체 텍스트 설정 필요
            routeScrollView.isHidden = true
            return
        }

        routeScrollView.isHidden = false

        for (index, route) in routes.enumerated() {
            let card = RouteCard(route: route, isSelected: index == selectedIndex)
            card.onTap = { [weak self] in
                self?.viewModel.selectRoute(at: index)
            }
            routeCardsStack.addArrangedSubview(card)
        }
    }

    // MARK: - Place search

    private func presentPlaceSearch(target: PlaceSearchTarget) {
        placeSearchTarget = target

        let buttonTitle = target == .departure ? "출발지로" : "도착지로"
        // TODO: DIContainer로 대체
        let searchPlacesUseCase = SearchPlacesUseCase(repository: MockPlaceSearchRepository())
        let searchViewModel = SearchPlaceCardViewModel(searchPlacesUseCase: searchPlacesUseCase)
        let searchVC = SearchPlaceCardViewController(
            viewModel: searchViewModel,
            selectionButtonTitle: buttonTitle,
            style: .dimmed(title: "장소 검색")
        )

        searchVC.onPlaceSelected = { [weak self] place in
            guard let self else { return }
            switch self.placeSearchTarget {
            case .departure:
                self.viewModel.setDeparture(place)
            case .arrival:
                self.viewModel.setDestination(place)
            }
        }

        present(searchVC, animated: true)
    }

    // MARK: - Time picker

    private func presentTimePicker() {
        let pickerViewController = DepartureTimePickerViewController(initialDate: viewModel.departureTime)
        pickerViewController.onDateSelected = { [weak self] date in
            self?.viewModel.setDepartureTime(date)
        }

        if let sheet = pickerViewController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }

        present(pickerViewController, animated: true)
    }

}
