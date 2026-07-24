//
//  SearchPlaceCardViewController.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-24.
//

import UIKit
import Combine

final class SearchPlaceCardViewController: UIViewController {

    enum Style {
        case plain
        case dimmed(title: String)
    }

    var onPlaceSelected: ((Place) -> Void)?

    private let style: Style
    private let viewModel: SearchPlaceCardViewModel
    private var cancellables = Set<AnyCancellable>()

    private var searchCard: SearchPlaceCard
    private var dimView: UIView?

    init(viewModel: SearchPlaceCardViewModel, selectionButtonTitle: String, style: Style = .plain) {
        self.style = style
        self.viewModel = viewModel

        switch style {
        case .plain:
            self.searchCard = SearchPlaceCard(selectionButtonTitle: selectionButtonTitle)
        case .dimmed(let title):
            self.searchCard = SearchPlaceCard(
                selectionButtonTitle: selectionButtonTitle,
                headerStyle: .titleWithCloseButton(title)
            )
        }

        super.init(nibName: nil, bundle: nil)

        if case .dimmed = style {
            modalPresentationStyle = .overFullScreen
            modalTransitionStyle = .crossDissolve
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLayout()
        setUpActions()
        bindViewModel()
    }

    // MARK: - Layout

    private func setUpLayout() {
        searchCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchCard)

        switch style {
        case .dimmed:
            let dim = UIView()
            dim.backgroundColor = .black.withAlphaComponent(0.4)
            dim.translatesAutoresizingMaskIntoConstraints = false
            view.insertSubview(dim, belowSubview: searchCard)
            self.dimView = dim

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimTapped(_:)))
            dim.addGestureRecognizer(tapGesture)

            NSLayoutConstraint.activate([
                dim.topAnchor.constraint(equalTo: view.topAnchor),
                dim.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                dim.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                dim.bottomAnchor.constraint(equalTo: view.bottomAnchor),

                searchCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
                searchCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
                searchCard.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                searchCard.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.7),
            ])

        case .plain:
            NSLayoutConstraint.activate([
                searchCard.topAnchor.constraint(equalTo: view.topAnchor),
                searchCard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                searchCard.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                searchCard.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        }
    }

    // MARK: - Actions

    private func setUpActions() {
        searchCard.onSearchTap = { [weak self] keyword in
            self?.viewModel.search(keyword: keyword)
        }

        searchCard.onPlaceTap = { [weak self] placeInfo in
            guard let self, let place = self.viewModel.place(for: placeInfo) else { return }
            self.onPlaceSelected?(place)
            if case .dimmed = self.style { self.dismiss(animated: true) }
        }

        searchCard.onFilterTap = { [weak self] placeType in
            self?.viewModel.toggleFilter(placeType)
        }

        searchCard.onResetFilterTap = { [weak self] in
            self?.viewModel.resetFilters()
        }

        searchCard.onClose = { [weak self] in
            self?.dismiss(animated: true)
        }
    }

    @objc private func dimTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !searchCard.frame.contains(location) {
            dismiss(animated: true)
        }
    }

    // MARK: - ViewModel binding

    private func bindViewModel() {
        viewModel.$filteredPlaces
            .receive(on: DispatchQueue.main)
            .sink { [weak self] places in
                let infos = places.map {
                    PlaceInfo(id: $0.id, name: $0.name, address: $0.address, tag: $0.type)
                }
                self?.searchCard.updatePlaces(infos)
            }
            .store(in: &cancellables)

        viewModel.$selectedFilters
            .receive(on: DispatchQueue.main)
            .sink { [weak self] filters in
                self?.searchCard.configureSelectedFilters(filters)
            }
            .store(in: &cancellables)

        viewModel.$hasSearched
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hasSearched in
                self?.searchCard.updateEmptyResultMessage(hasSearched: hasSearched)
            }
            .store(in: &cancellables)
    }

}
