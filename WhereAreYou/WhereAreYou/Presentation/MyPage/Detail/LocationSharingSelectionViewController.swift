//
//  LocationSharingSelectionViewController.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/25/26.
//

import UIKit

final class LocationSharingSelectionViewController: UIViewController {

    var onOptionSelected: ((LocationSharingOption) -> Void)?

    private var selectedOption: LocationSharingOption
    private let card = MyPageCardView()
    private var rowsByOption: [LocationSharingOption: MyPageRow] = [:]

    init(selectedOption: LocationSharingOption) {
        self.selectedOption = selectedOption
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init(selectedOption:)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "위치 공유 설정"
        view.backgroundColor = .systemBackground
        setUpLayout()
        setUpRows()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setUpLayout() {
        card.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(card)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func setUpRows() {
        let options = LocationSharingOption.allCases
        for (index, option) in options.enumerated() {
            let row = makeOptionRow(for: option)
            rowsByOption[option] = row
            card.contentStack.addArrangedSubview(row)
            if index < options.count - 1 {
                let divider = makeDivider()
                card.contentStack.setCustomSpacing(6, after: row)
                card.contentStack.addArrangedSubview(divider)
                card.contentStack.setCustomSpacing(6, after: divider)
            }
        }
    }

    private func makeOptionRow(for option: LocationSharingOption) -> MyPageRow {
        let row = MyPageRow(
            icon: UIImage(systemName: option.iconName),
            title: option.title,
            accessoryView: makeRadioView(isSelected: option == selectedOption)
        )
        row.value = option.description
        row.onTap = { [weak self] in
            self?.selectOption(option)
        }
        return row
    }

    private func selectOption(_ option: LocationSharingOption) {
        guard option != selectedOption else { return }

        let previousOption = selectedOption
        selectedOption = option

        if let previousRow = rowsByOption[previousOption] {
            previousRow.setAccessoryView(makeRadioView(isSelected: false))
        }
        if let newRow = rowsByOption[option] {
            newRow.setAccessoryView(makeRadioView(isSelected: true))
        }

        onOptionSelected?(option)
    }

    private func makeRadioView(isSelected: Bool) -> UIView {
        let outer = UIView()
        outer.layer.cornerRadius = 12
        outer.layer.borderWidth = 2
        outer.layer.borderColor = isSelected ? UIColor.blue1.cgColor : UIColor.separator.cgColor
        outer.translatesAutoresizingMaskIntoConstraints = false
        outer.widthAnchor.constraint(equalToConstant: 24).isActive = true
        outer.heightAnchor.constraint(equalToConstant: 24).isActive = true

        if isSelected {
            let inner = UIView()
            inner.backgroundColor = .blue1
            inner.layer.cornerRadius = 7
            inner.translatesAutoresizingMaskIntoConstraints = false
            outer.addSubview(inner)
            NSLayoutConstraint.activate([
                inner.centerXAnchor.constraint(equalTo: outer.centerXAnchor),
                inner.centerYAnchor.constraint(equalTo: outer.centerYAnchor),
                inner.widthAnchor.constraint(equalToConstant: 14),
                inner.heightAnchor.constraint(equalToConstant: 14)
            ])
        }

        return outer
    }

    private func makeDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = .separator
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return divider
    }

}
