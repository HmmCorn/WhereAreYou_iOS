//
//  AppointmentListViewController.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/21/26.
//

import UIKit

final class AppointmentListViewController: UIViewController {

    private static let cardSpacing: CGFloat = 16

    private let viewModel = AppointmentListViewModel()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "약속 목록"
        label.font = .boldPreferredFont(forTextStyle: .title1)
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
        button.setImage(UIImage(systemName: "arrow.uturn.backward.circle.fill"), for: .normal)
        button.tintColor = .blue2
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpLayout()
        setUpActions()
        reloadCards()
    }

    private func setUpLayout() {
        [titleLabel, scrollView, emptyLabel, pastAppointmentButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),

            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 8),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -24),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -48),

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

    private func reloadCards() {
        contentStack.arrangedSubviews.forEach {
            contentStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let today = viewModel.todayAppointments
        let upcoming = viewModel.upcomingAppointments
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
        contentStack.addArrangedSubview(label)
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
        card.onChatTap = {
            print("\(item.title) 대화 열기")
        }
        card.onMapTap = {
            print("\(item.title) 지도 열기")
        }
        card.onToggleNotification = { [weak self] in
            self?.viewModel.toggleNotification(id: item.id)
            self?.reloadCards()
        }
        card.onLeave = { [weak self] in
            self?.presentLeaveConfirmAlert(id: item.id, title: item.title)
        }

        contentStack.addArrangedSubview(card)
    }

    private func presentLeaveConfirmAlert(id: String, title: String) {
        let alert = UIAlertController(
            title: "약속 나가기",
            message: "'\(title)' 약속에서 나가시겠어요?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "나가기", style: .destructive) { [weak self] _ in
            self?.viewModel.leave(id: id)
            self?.reloadCards()
        })
        present(alert, animated: true)
    }

    private func presentPastAppointmentList() {
        print("지난 약속 화면으로 이동")
    }

}
