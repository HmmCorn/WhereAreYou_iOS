//
//  HomeViewController.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/16/26.
//

import UIKit

final class HomeViewController: UIViewController {

    // MARK: - Logo

    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Logo"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let logoTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "어딘데"
        label.font = .preferredFont(forTextStyle: .title1)
        label.textAlignment = .center
        return label
    }()

    // MARK: - Action buttons

    private lazy var createButton = UIButton.filled(
        title: "약속 만들기",
        background: .blue2,
        tint: .white
    )

    private let joinButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "약속 참여하기"
        config.baseForegroundColor = .blue2
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        config.background.strokeColor = .blue2
        config.background.strokeWidth = 1
        let button = UIButton(configuration: config)
        return button
    }()

    // MARK: - Upcoming appointment section

    private let upcomingSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "얼마 남지 않은 약속"
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()

    private let upcomingStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpLayout()
        loadDummyData()
    }

    private func setUpLayout() {
        let logoStack = UIStackView(arrangedSubviews: [logoImageView, logoTitleLabel])
        logoStack.axis = .vertical
        logoStack.alignment = .center
        logoStack.spacing = 8
        logoImageView.widthAnchor.constraint(equalToConstant: 64).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 64).isActive = true

        let buttonStack = UIStackView(arrangedSubviews: [createButton, joinButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 12

        let upcomingSection = UIStackView(arrangedSubviews: [upcomingSectionLabel, upcomingStack])
        upcomingSection.axis = .vertical
        upcomingSection.spacing = 12

        let contentStack = UIStackView(arrangedSubviews: [logoStack, buttonStack, upcomingSection])
        contentStack.axis = .vertical
        contentStack.spacing = 32
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func loadDummyData() {
        let dummy = UpcomingAppointment(
            id: "1",
            title: "고등학교 친구들과 저녁",
            participantCount: 5,
            location: AppointmentLocation(
                title: "고기굽는방앗간 이수역점",
                address: "",
                coordinate: Coordinate(latitude: 0, longitude: 0)
            ),
            date: Calendar.current.date(byAdding: .hour, value: 10, to: Date())
        )
        upcomingStack.addArrangedSubview(UpcomingAppointmentCard(appointment: dummy))
    }

}
