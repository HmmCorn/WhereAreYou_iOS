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

    private func reloadCards() {
        contentStack.arrangedSubviews.forEach {
            contentStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let pastAppointments = viewModel.pastAppointments
        emptyLabel.isHidden = !pastAppointments.isEmpty
        scrollView.isHidden = pastAppointments.isEmpty

        pastAppointments.forEach { addCard(for: $0) }
    }

    private func addCard(for item: AppointmentListItem) {
        let card = AppointmentListCard(item: item, accessoryView: nil)
        card.onChatTap = {
            print("\(item.title) 대화 열기")
        }
        card.onMapTap = {
            print("\(item.title) 지도 열기")
        }
        card.onLeave = { [weak self] in
            self?.presentDeleteConfirmAlert(id: item.id, title: item.title)
        }

        contentStack.addArrangedSubview(card)
    }

    private func presentDeleteConfirmAlert(id: String, title: String) {
        let alert = UIAlertController.leaveConfirmAlert(title: title) { [weak self] in
            self?.viewModel.delete(id: id)
            self?.reloadCards()
        }
        present(alert, animated: true)
    }

}
