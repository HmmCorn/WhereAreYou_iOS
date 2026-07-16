//
//  SearchPlaceCard.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-16.
//

import UIKit

final class SearchPlaceCard: UIView {

    var onSearchBarTap: (() -> Void)?
    var onSearchTap: (() -> Void)?

    var onResetFilterTap: (() -> Void)?
    var onFilterTap: ((PlaceType) -> Void)?

    var onPlaceTap: ((PlaceInfo) -> Void)?

    private let card = CardContainerView()
    private let searchBar = SearchBar()
    private let filterSection = FilterTagBox()

    private let resultScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()

    private let resultStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()

    private let places: [PlaceInfo]
    private let selectionButtonTitle: String
    private var cells: [PlaceCell] = []

    init(_ searchResult: [PlaceInfo], selectionButtonTitle: String) {
        self.places = searchResult
        self.selectionButtonTitle = selectionButtonTitle
        super.init(frame: .zero)
        setUpLayout()
        setUpActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init(_:selectionButtonTitle:)")
    }

    // MARK: - Layout

    private func setUpLayout() {
        translatesAutoresizingMaskIntoConstraints = false
        card.translatesAutoresizingMaskIntoConstraints = false
        addSubview(card)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: topAnchor),
            card.bottomAnchor.constraint(equalTo: bottomAnchor),
            card.leadingAnchor.constraint(equalTo: leadingAnchor),
            card.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        card.contentStack.addArrangedSubview(searchBar)
        card.contentStack.addArrangedSubview(filterSection)

        guard !places.isEmpty else { return }

        card.contentStack.addArrangedSubview(Self.makeDivider())
        card.contentStack.addArrangedSubview(resultScrollView)
        setUpResultScrollView()
    }

    private func setUpResultScrollView() {
        resultScrollView.translatesAutoresizingMaskIntoConstraints = false
        resultStack.translatesAutoresizingMaskIntoConstraints = false
        resultScrollView.addSubview(resultStack)

        NSLayoutConstraint.activate([
            resultStack.topAnchor.constraint(equalTo: resultScrollView.contentLayoutGuide.topAnchor),
            resultStack.bottomAnchor.constraint(equalTo: resultScrollView.contentLayoutGuide.bottomAnchor),
            resultStack.leadingAnchor.constraint(equalTo: resultScrollView.contentLayoutGuide.leadingAnchor),
            resultStack.trailingAnchor.constraint(equalTo: resultScrollView.contentLayoutGuide.trailingAnchor),
            resultStack.widthAnchor.constraint(equalTo: resultScrollView.frameLayoutGuide.widthAnchor)
        ])

        cells = places.map { place in
            let cell = PlaceCell(place, buttonText: selectionButtonTitle)
            if let lastCell = resultStack.arrangedSubviews.last {
                let divider = Self.makeDivider()
                resultStack.addArrangedSubview(divider)
                resultStack.setCustomSpacing(10, after: lastCell)
                resultStack.setCustomSpacing(10, after: divider)
            }
            resultStack.addArrangedSubview(cell)
            return cell
        }
    }

    private static func makeDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = .separator
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return divider
    }

    // MARK: - Actions

    private func setUpActions() {
        searchBar.onSearchTap = { [weak self] in self?.onSearchTap?() }
        filterSection.onResetTap = { [weak self] in self?.onResetFilterTap?() }
        filterSection.onFilterTap = { [weak self] placeType in self?.onFilterTap?(placeType) }

        for (place, cell) in zip(places, cells) {
            cell.onButtonTap = { [weak self] in self?.onPlaceTap?(place) }
        }

        let dismissKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissKeyboardGesture.cancelsTouchesInView = false
        dismissKeyboardGesture.delegate = self
        addGestureRecognizer(dismissKeyboardGesture)
    }

    @objc private func dismissKeyboard() { endEditing(true) }

    // MARK: - Public Configuration

    func configureSelectedFilters(_ selected: Set<PlaceType>) {
        filterSection.configure(selected: selected)
    }

}

extension SearchPlaceCard: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        !(touch.view is UITextField)
    }
}
