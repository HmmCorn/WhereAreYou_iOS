//
//  SharedPlacesViewController.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-03.
//

import UIKit
import Combine

final class SharedPlacesViewController: UIViewController {

    enum SortOrder {
        case newest
        case oldest
    }

    private let appointmentID: String
    private let fetchSharedPlacesUseCase: FetchSharedPlacesUseCase
    private let votePlaceUseCase: VotePlaceUseCase
    private let currentUserID: String

    private var sharedPlaces: [SharedPlace] = []
    private var sortOrder: SortOrder = .newest

    private let card: CardContainerView

    private let sortStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        return stack
    }()

    private lazy var newestButton: UIButton = makeSortButton(title: "최신순", isSelected: true)
    private lazy var oldestButton: UIButton = makeSortButton(title: "오래된순", isSelected: false)

    private let resultScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let resultStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "이 약속에서 공유된 장소가 없습니다"
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    init(
        appointmentID: String,
        currentUserID: String,
        fetchSharedPlacesUseCase: FetchSharedPlacesUseCase,
        votePlaceUseCase: VotePlaceUseCase
    ) {
        self.appointmentID = appointmentID
        self.currentUserID = currentUserID
        self.fetchSharedPlacesUseCase = fetchSharedPlacesUseCase
        self.votePlaceUseCase = votePlaceUseCase
        self.card = CardContainerView(headerStyle: .title("공유된 장소 모아보기"))
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpLayout()
        setUpActions()
        fetchPlaces()
    }

    // MARK: - Layout

    private func setUpLayout() {
        card.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(card)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: view.topAnchor),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        sortStack.addArrangedSubview(newestButton)
        sortStack.addArrangedSubview(oldestButton)

        card.contentStack.addArrangedSubview(sortStack)
        card.contentStack.addArrangedSubview(resultScrollView)

        resultScrollView.translatesAutoresizingMaskIntoConstraints = false
        resultStack.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        resultScrollView.addSubview(resultStack)
        resultScrollView.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            resultStack.topAnchor.constraint(equalTo: resultScrollView.contentLayoutGuide.topAnchor),
            resultStack.bottomAnchor.constraint(equalTo: resultScrollView.contentLayoutGuide.bottomAnchor),
            resultStack.leadingAnchor.constraint(equalTo: resultScrollView.contentLayoutGuide.leadingAnchor),
            resultStack.trailingAnchor.constraint(equalTo: resultScrollView.contentLayoutGuide.trailingAnchor),
            resultStack.widthAnchor.constraint(equalTo: resultScrollView.frameLayoutGuide.widthAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: resultScrollView.frameLayoutGuide.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: resultScrollView.frameLayoutGuide.centerYAnchor),
        ])
    }

    // MARK: - Actions

    private func setUpActions() {
        card.onClose = { [weak self] in
            self?.dismiss(animated: true)
        }

        newestButton.addAction(UIAction { [weak self] _ in
            self?.updateSortOrder(.newest)
        }, for: .touchUpInside)

        oldestButton.addAction(UIAction { [weak self] _ in
            self?.updateSortOrder(.oldest)
        }, for: .touchUpInside)
    }

    // MARK: - Data

    private func fetchPlaces() {
        fetchSharedPlacesUseCase.execute(appointmentID: appointmentID) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                if case .success(let places) = result {
                    self.sharedPlaces = places
                    self.rebuildCells()
                }
            }
        }
    }

    /// 투표 수 내림차순 정렬 후, 동일 투표 수에 대해 시간 정렬 적용
    private func sortedPlaces() -> [SharedPlace] {
        sharedPlaces.sorted { a, b in
            if a.voters.count != b.voters.count {
                return a.voters.count > b.voters.count
            }
            switch sortOrder {
            case .newest: return a.sharedAt > b.sharedAt
            case .oldest: return a.sharedAt < b.sharedAt
            }
        }
    }

    private func updateSortOrder(_ order: SortOrder) {
        sortOrder = order
        newestButton.configuration?.baseBackgroundColor = order == .newest ? .blue2 : .systemGray5
        newestButton.configuration?.baseForegroundColor = order == .newest ? .white : .label
        oldestButton.configuration?.baseBackgroundColor = order == .oldest ? .blue2 : .systemGray5
        oldestButton.configuration?.baseForegroundColor = order == .oldest ? .white : .label
        rebuildCells()
    }

    private func rebuildCells() {
        resultStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let sorted = sortedPlaces()
        guard !sorted.isEmpty else {
            emptyLabel.isHidden = false
            return
        }

        emptyLabel.isHidden = true

        for (index, shared) in sorted.enumerated() {
            let item = SharedPlaceItem(
                id: shared.id,
                placeName: shared.place.name,
                placeAddress: shared.place.address,
                voterProfileImages: shared.voters.map { $0.profileImage.lastPathComponent },
                voterCount: shared.voters.count,
                hasVoted: shared.voters.contains { $0.id == currentUserID },
                sharedAt: shared.sharedAt
            )

            if index > 0 {
                let divider = makeDivider()
                resultStack.addArrangedSubview(divider)
            }

            let cell = SharedPlaceCell(item: item)
            cell.onVoteTap = { [weak self] in
                self?.voteForPlace(placeID: shared.id)
            }
            resultStack.addArrangedSubview(cell)
        }
    }

    private func voteForPlace(placeID: String) {
        votePlaceUseCase.execute(appointmentID: appointmentID, placeID: placeID) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                if case .success(let updatedPlace) = result {
                    if let index = self.sharedPlaces.firstIndex(where: { $0.id == placeID }) {
                        self.sharedPlaces[index] = updatedPlace
                    }
                    self.rebuildCells()
                }
            }
        }
    }

    // MARK: - Helpers

    private func makeSortButton(title: String, isSelected: Bool) -> UIButton {
        UIButton.filled(
            title: title,
            background: isSelected ? .blue2 : .systemGray5,
            tint: isSelected ? .white : .label,
            font: .caption1,
            edgeInsets: NSDirectionalEdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10)
        )
    }

    private func makeDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = .separator
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return divider
    }

}
