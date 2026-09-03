//
//  AppointmentListViewController.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/21/26.
//

import UIKit

final class AppointmentListViewController: UIViewController {

    private static let cardSpacing: CGFloat = 16
    private static let cardLeadingInset: CGFloat = 40
    private static let sectionHeaderLeadingInset: CGFloat = 26
    private static let sectionHeaderTopSpacing: CGFloat = 18
    private static let sectionHeaderBottomSpacing: CGFloat = 10

    private let viewModel = AppointmentListViewModel()
    weak var coordinator: AppointmentListCoordinating?

    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: .logo)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "약속 목록"
        label.font = .boldPreferredFont(forTextStyle: .title1)
        label.textColor = .blue1
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
        label.text = "약속이 없습니다."
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private let pastAppointmentButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.tintColor = .black
        button.layer.cornerRadius = 24
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowRadius = 4
        button.layer.shadowOffset = CGSize(width: 0, height: 2)

        let symbolConfiguration = UIImage.SymbolConfiguration(
            font: .systemFont(ofSize: 19, weight: .semibold)
        )
        button.setImage(
            UIImage(
                systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90",
                withConfiguration: symbolConfiguration
            ),
            for: .normal
        )
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpLayout()
        setUpActions()
        reloadCards()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func setUpLayout() {
        [logoImageView, titleLabel, scrollView, emptyLabel, pastAppointmentButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            logoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logoImageView.widthAnchor.constraint(equalToConstant: 77),
            logoImageView.heightAnchor.constraint(equalToConstant: 48),

            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 8),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: Self.cardLeadingInset),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -Self.cardLeadingInset),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -(Self.cardLeadingInset * 2)),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            pastAppointmentButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            pastAppointmentButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            pastAppointmentButton.widthAnchor.constraint(equalToConstant: 48),
            pastAppointmentButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func setUpActions() {
        pastAppointmentButton.addAction(UIAction { [weak self] _ in
            self?.presentPastAppointmentList()
        }, for: .touchUpInside)
    }

    private func reloadCards(
        today: [AppointmentListItem]? = nil,
        upcoming: [AppointmentListItem]? = nil
    ) {
        let today = today ?? viewModel.todayAppointments
        let upcoming = upcoming ?? viewModel.upcomingAppointments

        contentStack.arrangedSubviews.forEach {
            contentStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let hasAnyAppointment = !today.isEmpty || !upcoming.isEmpty

        emptyLabel.isHidden = hasAnyAppointment
        scrollView.isHidden = !hasAnyAppointment

        if !today.isEmpty {
            addSectionHeaderIfNeeded(title: "오늘 약속", isNeeded: !upcoming.isEmpty)
            today.forEach { addCard(for: $0) }
        }

        if !upcoming.isEmpty {
            addSectionHeaderIfNeeded(title: "예정된 약속", isNeeded: !today.isEmpty)
            upcoming.forEach { addCard(for: $0) }
        }
    }

    private func addSectionHeaderIfNeeded(title: String, isNeeded: Bool) {
        guard isNeeded else { return }

        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .callout)
        label.textColor = .secondaryLabel

        let headerContainer = UIView()
        label.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            label.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            label.leadingAnchor.constraint(
                equalTo: headerContainer.leadingAnchor,
                constant: Self.sectionHeaderLeadingInset - Self.cardLeadingInset
            ),
            label.trailingAnchor.constraint(lessThanOrEqualTo: headerContainer.trailingAnchor)
        ])

        if let previousView = contentStack.arrangedSubviews.last {
            contentStack.setCustomSpacing(Self.sectionHeaderTopSpacing, after: previousView)
        }
        contentStack.addArrangedSubview(headerContainer)
        contentStack.setCustomSpacing(Self.sectionHeaderBottomSpacing, after: headerContainer)
    }

    private func addCard(for item: AppointmentListItem) {
        let remainingTimeLabel: UILabel = {
            let label = UILabel()
            label.font = .boldPreferredFont(forTextStyle: .footnote)
            label.textColor = .blue2
            label.text = item.date?.remainingTimeText
            return label
        }()

        let card = AppointmentListCard(item: item, accessoryView: remainingTimeLabel)
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
            let (today, upcoming) = viewModel.leave(id: id)
            reloadCards(today: today, upcoming: upcoming)
        }
        present(alert, animated: true)
    }

    private func presentPastAppointmentList() {
        coordinator?.showPastAppointmentList()
    }

    // MARK: - Chat / Route

    private func presentChat(appointmentID: String) {
        coordinator?.showChat(appointmentID: appointmentID)
    }

    private func presentAppointmentRoute(appointmentID: String) {
        coordinator?.showAppointmentRoute(appointmentID: appointmentID)
    }

}
