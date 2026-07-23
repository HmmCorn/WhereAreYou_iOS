//
//  DepartureTimePickerViewController.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-22.
//

import UIKit

final class DepartureTimePickerViewController: UIViewController {

    var onDateSelected: ((Date) -> Void)?

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
        font: .body
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

        let stack = UIStackView(arrangedSubviews: [datePicker, confirmButton])
        stack.axis = .vertical
        stack.spacing = 20

        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])

        confirmButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.onDateSelected?(self.datePicker.date)
            self.dismiss(animated: true)
        }, for: .touchUpInside)
    }

}
