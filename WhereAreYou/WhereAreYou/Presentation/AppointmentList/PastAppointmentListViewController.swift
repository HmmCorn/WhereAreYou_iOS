//
//  PastAppointmentListViewController.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/21/26.
//

import UIKit

final class PastAppointmentListViewController: UIViewController {

    private static let cardSpacing: CGFloat = 16

    private let viewModel = PastAppointmentListViewModel()
    weak var coordinator: AppointmentListCoordinator?

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "30일 이내의 지난 약속이 보관됩니다.\n약속을 길게 눌러 삭제할 수 있습니다."
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let scrollView = UIScrollView()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Self.cardSpacing
        return stack
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "지난 약속이 없습니다."
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "지난 약속"
        view.backgroundColor = .systemBackground
        setUpLayout()
        reloadCards()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setUpLayout() {
        [descriptionLabel, scrollView, emptyLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            scrollView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 8),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 40),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -40),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -80),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func reloadCards(pastAppointments: [AppointmentListItem]? = nil) {
        let pastAppointments = pastAppointments ?? viewModel.pastAppointments

        contentStack.arrangedSubviews.forEach {
            contentStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        emptyLabel.isHidden = !pastAppointments.isEmpty
        scrollView.isHidden = pastAppointments.isEmpty

        pastAppointments.forEach { addCard(for: $0) }
    }

    private func addCard(for item: AppointmentListItem) {
        let card = AppointmentListCard(item: item, accessoryView: nil)
        card.onChatTap = { [weak self] in
            self?.presentChat(appointmentID: item.id)
        }
        card.onMapTap = { [weak self] in
            self?.presentAppointmentRoute(appointmentID: item.id)
        }
        card.contextMenuProvider = { [weak self] in
            self?.makeContextMenu(id: item.id) ?? UIMenu(children: [])
        }

        contentStack.addArrangedSubview(card)
    }

    private func makeContextMenu(id: String) -> UIMenu {
        guard let item = viewModel.item(id: id) else { return UIMenu(children: []) }

        let notificationAction = UIAction(
            title: viewModel.notificationMenuTitle(for: item),
            image: UIImage(systemName: viewModel.notificationMenuIcon(for: item))
        ) { [weak self] _ in
            self?.viewModel.toggleNotification(id: item.id)
        }

        let leaveAction = UIAction(
            title: "약속 나가기",
            image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
            attributes: .destructive
        ) { [weak self] _ in
            self?.presentLeaveConfirmAlert(id: item.id, title: item.title)
        }

        return UIMenu(children: [notificationAction, leaveAction])
    }

    private func presentLeaveConfirmAlert(id: String, title: String) {
        let alert = UIAlertController.leaveConfirmAlert(title: title) { [weak self] in
            guard let self else { return }
            let updated = viewModel.leave(id: id)
            reloadCards(pastAppointments: updated)
        }
        present(alert, animated: true)
    }

    // MARK: - Chat / Route

    private func presentChat(appointmentID: String) {
        coordinator?.showChat(appointmentID: appointmentID)
    }

    private func presentAppointmentRoute(appointmentID: String) {
        coordinator?.showAppointmentRoute(appointmentID: appointmentID)
    }

}
