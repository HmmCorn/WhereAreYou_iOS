//
//  RouteSearchViewController.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-22.
//

import UIKit

final class RouteSearchViewController: UIViewController {

    // MARK: - Spacing

    private static let horizontalPadding: CGFloat = 20
    private static let sectionSpacing: CGFloat = 24
    private static let sectionHeaderBottomSpacing: CGFloat = 12
    private static let bottomButtonHeight: CGFloat = 50
    private static let bottomButtonBottomPadding: CGFloat = 16
    private static let contentTopPadding: CGFloat = 16
    private static let contentBottomPadding: CGFloat = 80

    // MARK: - Scroll

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()

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

    private var placeSearchOverlay: UIView?

    // MARK: - Date formatting

    private static let departureTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월 d일 (E) a h:mm"
        return f
    }()

    // MARK: - Init

    private let initialDeparture: Place?
    private let initialDestination: Place?

    init(departure: Place? = nil, destination: Place? = nil) {
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

    private func setUpInitialPlaces() {
        if let dep = initialDeparture {
            placeInputView.setDeparture(name: dep.name)
        }
        if let dest = initialDestination {
            placeInputView.setArrival(name: dest.name)
        }
    }

    // MARK: - Layout

    private func setUpLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        selectRouteButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        view.addSubview(selectRouteButton)
        scrollView.addSubview(contentStack)

        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: Self.contentTopPadding,
            leading: Self.horizontalPadding,
            bottom: Self.contentBottomPadding,
            trailing: Self.horizontalPadding
        )

        let timeSectionRow = makeTimeSectionRow()

        [placeInputView, transportSectionLabel, transportSelector,
         timeSectionRow, routeSectionLabel, emptyStateLabel,
         loadingIndicator, routeCardsStack]
            .forEach { contentStack.addArrangedSubview($0) }

        contentStack.setCustomSpacing(Self.sectionSpacing, after: placeInputView)
        contentStack.setCustomSpacing(Self.sectionHeaderBottomSpacing, after: transportSectionLabel)
        contentStack.setCustomSpacing(Self.sectionSpacing, after: transportSelector)
        contentStack.setCustomSpacing(Self.sectionSpacing, after: timeSectionRow)
        contentStack.setCustomSpacing(Self.sectionHeaderBottomSpacing, after: routeSectionLabel)
        contentStack.setCustomSpacing(Self.sectionHeaderBottomSpacing, after: emptyStateLabel)
        contentStack.setCustomSpacing(Self.sectionHeaderBottomSpacing, after: loadingIndicator)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            selectRouteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Self.horizontalPadding),
            selectRouteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Self.horizontalPadding),
            selectRouteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Self.bottomButtonBottomPadding),
            selectRouteButton.heightAnchor.constraint(equalToConstant: Self.bottomButtonHeight),
        ])

        routeCardsStack.isHidden = true
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
        placeInputView.onDepartureTapped = { }
        placeInputView.onArrivalTapped = { }
        placeInputView.onCurrentLocationTapped = { }
        placeInputView.onDepartureClear = { }
        placeInputView.onArrivalClear = { }

        transportSelector.onTransportTypeSelected = { _ in }

        timeButton.addAction(UIAction { [weak self] _ in
            self?.presentTimePicker()
        }, for: .touchUpInside)

        selectRouteButton.addAction(UIAction { _ in
            print("경로 선택 tapped")
        }, for: .touchUpInside)
    }

    // MARK: - ViewModel binding

    private func bindViewModel() { }

    // MARK: - Place search overlay

    private func presentPlaceSearchOverlay(title: String) {
        let overlay = UIView()
        overlay.backgroundColor = .black.withAlphaComponent(0.4)
        overlay.translatesAutoresizingMaskIntoConstraints = false

        // TODO: 임시 카드
        let card = CardContainerView(headerStyle: .titleWithCloseButton(title))
        card.translatesAutoresizingMaskIntoConstraints = false
        card.onClose = { [weak self] in
            self?.dismissPlaceSearchOverlay()
        }

        overlay.addSubview(card)
        view.addSubview(overlay)
        placeSearchOverlay = overlay

        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            card.leadingAnchor.constraint(equalTo: overlay.leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(equalTo: overlay.trailingAnchor, constant: -24),
            card.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
        ])
    }

    private func dismissPlaceSearchOverlay() {
        placeSearchOverlay?.removeFromSuperview()
        placeSearchOverlay = nil
    }

    // MARK: - Current location

    private func setCurrentLocationAsDeparture() { }

    // MARK: - Time picker

    private func presentTimePicker() {
        let pickerViewController = DepartureTimePickerViewController(initialDate: .now)
        pickerViewController.onDateSelected = { _ in }

        if let sheet = pickerViewController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }

        present(pickerViewController, animated: true)
    }

}
