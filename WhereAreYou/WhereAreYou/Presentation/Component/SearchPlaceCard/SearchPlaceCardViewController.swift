//
//  SearchPlaceCardViewController.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-24.
//

import UIKit
import Combine

final class SearchPlaceCardViewController: UIViewController {

    var onPlaceSelected: ((Place) -> Void)?

    private let viewModel: SearchPlaceCardViewModel
    private var cancellables = Set<AnyCancellable>()

    private var searchCard: SearchPlaceCard
    private var dimView = UIView()

    init(viewModel: SearchPlaceCardViewModel, selectionButtonTitle: String) {
        self.viewModel = viewModel
        self.searchCard = SearchPlaceCard(selectionButtonTitle: selectionButtonTitle)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
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
        dimView.backgroundColor = .black.withAlphaComponent(0.4)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimTapped(_:)))
        dimView.addGestureRecognizer(tapGesture)

        searchCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchCard)

        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            searchCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            searchCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            searchCard.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            searchCard.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.7),
        ])
    }

    // MARK: - Actions

    private func setUpActions() {
        searchCard.onSearchTap = { [weak self] keyword in
            self?.viewModel.search(keyword: keyword)
        }

        searchCard.onPlaceTap = { [weak self] placeInfo in
            guard let self, let place = self.viewModel.place(for: placeInfo) else { return }
            self.onPlaceSelected?(place)
            self.dismiss(animated: true)
        }

        searchCard.onFilterTap = { [weak self] placeType in
            self?.viewModel.toggleFilter(placeType)
        }

        searchCard.onResetFilterTap = { [weak self] in
            self?.viewModel.resetFilters()
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
    }

}
