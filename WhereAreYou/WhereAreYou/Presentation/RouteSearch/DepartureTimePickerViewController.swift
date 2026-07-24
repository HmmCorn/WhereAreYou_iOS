//
//  DepartureTimePickerViewController.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-22.
//

import UIKit

final class DepartureTimePickerViewController: UIViewController {

    var onDateSelected: ((Date) -> Void)?

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "출발 시간 설정"
        label.font = .preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        return label
    }()

    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko_KR")
        return picker
    }()

    private let confirmButton = UIButton.filled(
        title: "확인",
        background: .blue1,
        tint: .white,
        font: .body,
        edgeInsets: NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
    )

    private let initialDate: Date

    init(initialDate: Date) {
        self.initialDate = initialDate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        datePicker.minimumDate = Date()
        datePicker.date = initialDate

        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(headerLabel)
        view.addSubview(datePicker)
        view.addSubview(confirmButton)

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            datePicker.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 16),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])

        confirmButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.onDateSelected?(self.datePicker.date)
            self.dismiss(animated: true)
        }, for: .touchUpInside)
    }

}
