//
//  SearchPlaceCard.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-16.
//

import UIKit

final class SearchPlaceCard: UIView {

    var onSearchBarTap: (() -> Void)?
    var onSearchTap: ((String) -> Void)?

    var onResetFilterTap: (() -> Void)?
    var onFilterTap: ((PlaceType) -> Void)?

    var onPlaceTap: ((PlaceInfo) -> Void)?
    var onClose: (() -> Void)?

    private let card: CardContainerView
    private let searchBar = SearchBar()
    private let filterSection = FilterTagBox()

    private let resultScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delaysContentTouches = false
        return scrollView
    }()

    private let resultStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()

    private let emptyResultLabel: UILabel = {
        let label = UILabel()
        label.text = "장소를 검색해주세요."
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private var resultDivider = {
        let divider = UIView()
        divider.backgroundColor = .separator
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return divider
    }()

    private var places: [PlaceInfo] = []
    private let selectionButtonTitle: String
    private var cells: [PlaceCell] = []

    init(selectionButtonTitle: String, headerStyle: CardContainerView.HeaderStyle = .none) {
        self.selectionButtonTitle = selectionButtonTitle
        self.card = CardContainerView(headerStyle: headerStyle)
        super.init(frame: .zero)
        setUpLayout()
        setUpActions()
        card.onClose = { [weak self] in self?.onClose?() }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init(selectionButtonTitle:)")
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
        card.contentStack.addArrangedSubview(resultDivider)
        card.contentStack.addArrangedSubview(resultScrollView)

        setUpResultScrollViewConstraints()

        resultDivider.isHidden = true
        emptyResultLabel.isHidden = false
    }

    private func setUpResultScrollViewConstraints() {
        resultScrollView.translatesAutoresizingMaskIntoConstraints = false
        resultStack.translatesAutoresizingMaskIntoConstraints = false
        emptyResultLabel.translatesAutoresizingMaskIntoConstraints = false

        resultScrollView.addSubview(resultStack)
        resultScrollView.addSubview(emptyResultLabel)

        NSLayoutConstraint.activate([
            resultScrollView.heightAnchor.constraint(equalToConstant: 300),

            resultStack.topAnchor.constraint(equalTo: resultScrollView.contentLayoutGuide.topAnchor),
            resultStack.bottomAnchor.constraint(equalTo: resultScrollView.contentLayoutGuide.bottomAnchor),
            resultStack.leadingAnchor.constraint(equalTo: resultScrollView.contentLayoutGuide.leadingAnchor),
            resultStack.trailingAnchor.constraint(equalTo: resultScrollView.contentLayoutGuide.trailingAnchor),
            resultStack.widthAnchor.constraint(equalTo: resultScrollView.frameLayoutGuide.widthAnchor),

            emptyResultLabel.centerXAnchor.constraint(equalTo: resultScrollView.frameLayoutGuide.centerXAnchor),
            emptyResultLabel.centerYAnchor.constraint(equalTo: resultScrollView.frameLayoutGuide.centerYAnchor),
        ])
    }

    private static func makeDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = .separator
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return divider
    }

    // MARK: - Actions

    private func setUpActions() {
        searchBar.onSearchTap = { [weak self] in
            guard let self else { return }
            self.onSearchTap?(self.searchBar.text ?? "")
        }
        filterSection.onResetTap = { [weak self] in self?.onResetFilterTap?() }
        filterSection.onFilterTap = { [weak self] placeType in self?.onFilterTap?(placeType) }

        let dismissKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissKeyboardGesture.cancelsTouchesInView = false
        dismissKeyboardGesture.delegate = self
        addGestureRecognizer(dismissKeyboardGesture)
    }

    @objc private func dismissKeyboard() { endEditing(true) }

    // MARK: - Public Configuration

    func updatePlaces(_ newPlaces: [PlaceInfo]) {
        places = newPlaces
        rebuildResultCells()
    }

    func configureSelectedFilters(_ selected: [PlaceType]) {
        filterSection.configure(selected: selected)
    }

    func setSearching(_ isSearching: Bool) {
        if isSearching {
            emptyResultLabel.isHidden = true
        }
    }

    func updateEmptyResultMessage(hasSearched: Bool) {
        emptyResultLabel.text = hasSearched ? "검색 결과가 존재하지 않습니다." : "장소를 검색해주세요."
    }

    // MARK: - Result Cells

    private func rebuildResultCells() {
        resultStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        cells = []

        guard !places.isEmpty else {
            emptyResultLabel.isHidden = false
            resultDivider.isHidden = true
            return
        }

        emptyResultLabel.isHidden = true
        resultDivider.isHidden = false

        cells = places.map { place in
            let cell = PlaceCell(place, buttonText: selectionButtonTitle)
            if let lastView = resultStack.arrangedSubviews.last {
                let divider = Self.makeDivider()
                resultStack.addArrangedSubview(divider)
                resultStack.setCustomSpacing(10, after: lastView)
                resultStack.setCustomSpacing(10, after: divider)
            }
            resultStack.addArrangedSubview(cell)
            cell.onButtonTap = { [weak self] in self?.onPlaceTap?(place) }
            return cell
        }
    }

}

extension SearchPlaceCard: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        !(touch.view is UITextField)
    }
}
