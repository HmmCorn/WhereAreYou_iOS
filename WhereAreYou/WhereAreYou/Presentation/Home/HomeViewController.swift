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

        let baseDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2)
        if let boldDescriptor = baseDescriptor.withSymbolicTraits(.traitBold) {
            label.font = UIFont(descriptor: boldDescriptor, size: 0)
        } else {
            label.font = UIFont.preferredFont(forTextStyle: .title2)
        }

        label.textColor = .blue1
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    // MARK: - Action buttons

    private let createButton: UIButton = {
        let button = UIButton.filled(
            title: "약속 만들기", background: .blue2, tint: .white, font: .preferredFont(forTextStyle: .headline)
        )
        button.configuration?.image = UIImage(systemName: "calendar.and.person")
        button.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(
            font: .preferredFont(forTextStyle: .title2)
        ).applying(UIImage.SymbolConfiguration(weight: .bold))
        button.configuration?.imagePlacement = .leading
        button.configuration?.imagePadding = 32

        button.heightAnchor.constraint(equalToConstant: 73).isActive = true
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.cornerRadius = 20

        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowRadius = 2
        button.layer.shadowOffset = CGSize(width: 0, height: 4)

        return button
    }()

    private let joinButton: UIButton = {
        let button = UIButton.filled(
            title: "약속 참여하기", background: .white, tint: .blue2, font: .preferredFont(forTextStyle: .headline)
        )
        button.configuration?.image = UIImage(systemName: "person.line.dotted.person.fill")
        button.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(
            font: .preferredFont(forTextStyle: .title2)
        ).applying(UIImage.SymbolConfiguration(weight: .bold))
        button.configuration?.imagePlacement = .leading
        button.configuration?.imagePadding = 22

        button.heightAnchor.constraint(equalToConstant: 73).isActive = true
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.blue2.cgColor
        button.layer.cornerRadius = 20

        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowRadius = 2
        button.layer.shadowOffset = CGSize(width: 0, height: 4)

        return button
    }()

    // MARK: - Upcoming appointment section

    private let upcomingSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "얼마 남지 않은 약속"
        label.font = .preferredFont(forTextStyle: .callout)
        label.textColor = .secondaryLabel
        return label
    }()

    private let upcomingCard = UpcomingAppointmentCard(
        appointment: UpcomingAppointment(
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
    )

    // MARK: - Join sheet

    private var joinSheetOverlay: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpLayout()
        setUpActions()
    }

    private func setUpLayout() {
        [logoImageView, logoTitleLabel, createButton, joinButton, upcomingSectionLabel, upcomingCard]
            .forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview($0)
            }

        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 43),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 119),
            logoImageView.heightAnchor.constraint(equalToConstant: 74),

            logoTitleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor),
            logoTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            createButton.topAnchor.constraint(equalTo: logoTitleLabel.bottomAnchor, constant: 60),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            joinButton.topAnchor.constraint(equalTo: createButton.bottomAnchor, constant: 45),
            joinButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            joinButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            upcomingSectionLabel.topAnchor.constraint(equalTo: joinButton.bottomAnchor, constant: 88),
            upcomingSectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),

            upcomingCard.topAnchor.constraint(equalTo: upcomingSectionLabel.bottomAnchor, constant: 12),
            upcomingCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            upcomingCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }

    private func setUpActions() {
        joinButton.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
    }

    // MARK: - Join sheet

    @objc private func joinButtonTapped() {
        presentJoinSheet()
    }

    private func presentJoinSheet() {
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        overlay.translatesAutoresizingMaskIntoConstraints = false

        let sheet = JoinAppointmentSheet()
        sheet.onCancel = { [weak self] in self?.dismissJoinSheet() }
        sheet.onJoin = { code in
            print("HomeViewController received join code: \(code)")
        }

        overlay.addSubview(sheet)
        view.addSubview(overlay)
        joinSheetOverlay = overlay

        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            sheet.leadingAnchor.constraint(equalTo: overlay.leadingAnchor, constant: 24),
            sheet.trailingAnchor.constraint(equalTo: overlay.trailingAnchor, constant: -24),
            sheet.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
        ])
    }

    private func dismissJoinSheet() {
        joinSheetOverlay?.removeFromSuperview()
        joinSheetOverlay = nil
    }

}
