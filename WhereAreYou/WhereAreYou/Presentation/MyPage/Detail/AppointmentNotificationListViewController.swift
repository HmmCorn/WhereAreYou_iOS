//
//  AppointmentNotificationListViewController.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/25/26.
//

import UIKit

final class AppointmentNotificationListViewController: UIViewController {

    private static let cardSpacing: CGFloat = 16

    private let viewModel: MyPageViewModel

    private let scrollView = UIScrollView()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Self.cardSpacing
        return stack
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "알림을 설정할 약속이 없습니다."
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init(viewModel:)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "약속별 알림"
        view.backgroundColor = .systemBackground
        setUpLayout()
        reloadCards()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setUpLayout() {
        [scrollView, emptyLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 8),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func reloadCards() {
        let items = viewModel.appointmentNotifications

        contentStack.arrangedSubviews.forEach {
            contentStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        emptyLabel.isHidden = !items.isEmpty
        scrollView.isHidden = items.isEmpty

        items.forEach { addCard(for: $0) }
    }

    private func addCard(for item: AppointmentListItem) {
        let card = AppointmentNotificationCard(item: item)
        card.onNotificationToggle = { [weak self] _ in
            self?.viewModel.toggleNotification(id: item.id)
        }
        contentStack.addArrangedSubview(card)
    }

}
