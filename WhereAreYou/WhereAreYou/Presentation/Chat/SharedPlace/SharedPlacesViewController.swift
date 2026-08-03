//
//  SharedPlacesViewController.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-03.
//

import UIKit
import Combine

final class SharedPlacesViewController: UIViewController {

    private let viewModel: SharedPlacesViewModel
    private var cancellables = Set<AnyCancellable>()

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

    init(viewModel: SharedPlacesViewModel) {
        self.viewModel = viewModel
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
        bindViewModel()
        viewModel.fetchPlaces()
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
            self?.viewModel.updateSortOrder(.newest)
        }, for: .touchUpInside)

        oldestButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.updateSortOrder(.oldest)
        }, for: .touchUpInside)
    }

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.rebuildCells(items: items)
            }
            .store(in: &cancellables)

        viewModel.$sortOrder
            .receive(on: DispatchQueue.main)
            .sink { [weak self] order in
                self?.updateSortButtons(order)
            }
            .store(in: &cancellables)
    }

    // MARK: - UI Update

    private func rebuildCells(items: [SharedPlaceItem]) {
        resultStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        guard !items.isEmpty else {
            emptyLabel.isHidden = false
            return
        }

        emptyLabel.isHidden = true

        for (index, item) in items.enumerated() {
            if index > 0 {
                resultStack.addArrangedSubview(makeDivider())
            }

            let cell = SharedPlaceCell(item: item)
            cell.onVoteTap = { [weak self] in
                self?.viewModel.voteForPlace(id: item.id)
            }
            resultStack.addArrangedSubview(cell)
        }
    }

    private func updateSortButtons(_ order: SharedPlacesViewModel.SortOrder) {
        newestButton.configuration?.baseBackgroundColor = order == .newest ? .blue2 : .systemGray5
        newestButton.configuration?.baseForegroundColor = order == .newest ? .white : .label
        oldestButton.configuration?.baseBackgroundColor = order == .oldest ? .blue2 : .systemGray5
        oldestButton.configuration?.baseForegroundColor = order == .oldest ? .white : .label
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
