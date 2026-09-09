//
//  MyPageViewController.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/25/26.
//

import UIKit

final class MyPageViewController: UIViewController {

    private static let cardSpacing: CGFloat = 16

    private let viewModel: MyPageViewModel
    weak var coordinator: MyPageCoordinating?

    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init(viewModel:)")
    }

    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: .logo)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "마이페이지"
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

    // MARK: - 프로필 카드

    private let profileCard = MyPageCardView()
    private let profileEditIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "pencil"))
        imageView.tintColor = .tertiaryLabel
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        return imageView
    }()
    private lazy var profileRow = MyPageRow(
        icon: UIImage(named: viewModel.profile.profileImageName) ?? UIImage(systemName: viewModel.profile.profileImageName),
        title: "닉네임",
        isCircularImage: true,
        accessoryView: profileEditIcon
    )

    // MARK: - 위치 카드

    private let locationCard = MyPageCardView()
    private let locationSharingRow = MyPageRow(icon: UIImage(systemName: "location"), title: "위치 공유 설정")
    private let locationPermissionRow = MyPageRow(icon: UIImage(systemName: "location.circle"), title: "위치 권한 설정")

    // MARK: - 알림 카드

    private let notificationCard = MyPageCardView()
    private let notificationSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = .blue2
        return toggle
    }()
    private lazy var notificationRow = MyPageRow(
        icon: UIImage(systemName: "bell"),
        title: "전체 알림",
        accessoryView: notificationSwitch,
        accessoryHasOwnInteraction: true
    )
    private let appointmentNotificationRow = MyPageRow(
        icon: UIImage(systemName: "text.bubble"),
        title: "약속별 알림"
    )

    // MARK: - 기타 카드

    private let etcCard = MyPageCardView()
    private let appInfoRow = MyPageRow(icon: UIImage(systemName: "info.circle"), title: "앱 정보")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpLayout()
        setUpActions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        reloadContent()
    }

    private func setUpLayout() {
        [logoImageView, titleLabel, scrollView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        setUpCard(profileCard, rows: [profileRow])
        setUpCard(locationCard, rows: [locationSharingRow, locationPermissionRow])
        setUpCard(notificationCard, rows: [notificationRow, appointmentNotificationRow])
        setUpCard(etcCard, rows: [appInfoRow])

        [profileCard, locationCard, notificationCard, etcCard].forEach {
            contentStack.addArrangedSubview($0)
        }

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
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])
    }

    private func setUpCard(_ card: MyPageCardView, rows: [MyPageRow]) {
        for (index, row) in rows.enumerated() {
            card.contentStack.addArrangedSubview(row)
            if index < rows.count - 1 {
                let divider = makeDivider()
                card.contentStack.setCustomSpacing(6, after: row)
                card.contentStack.addArrangedSubview(divider)
                card.contentStack.setCustomSpacing(6, after: divider)
            }
        }
    }

    private func makeDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = .separator
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return divider
    }

    private func setUpActions() {
        profileRow.onTap = { [weak self] in
            self?.presentProfileEdit()
        }
        locationSharingRow.onTap = { [weak self] in
            self?.presentLocationSharingSelection()
        }
        locationPermissionRow.onTap = { [weak self] in
            self?.presentLocationPermission()
        }
        appointmentNotificationRow.onTap = { [weak self] in
            self?.presentAppointmentNotificationList()
        }
        appInfoRow.onTap = {
            print("앱 정보 탭")
        }

        notificationSwitch.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            viewModel.setNotificationEnabled(notificationSwitch.isOn)
        }, for: .valueChanged)
    }

    private func reloadContent() {
        let profile = viewModel.profile

        profileRow.value = profile.nickname
        profileRow.setIcon(UIImage(named: profile.profileImageName) ?? UIImage(systemName: profile.profileImageName))
        locationSharingRow.value = profile.locationSharingOption.title
        locationPermissionRow.value = viewModel.locationPermissionState.title
        notificationSwitch.isOn = profile.isNotificationEnabled
        notificationRow.value = profile.isNotificationEnabled ? "전체 알림 켜짐" : "전체 알림 꺼짐"

        let enabledCount = viewModel.appointmentNotifications.filter { $0.isNotificationEnabled }.count
        appointmentNotificationRow.value = "\(enabledCount)개의 약속 알림 켜짐"

        appInfoRow.value = "버전 정보"
    }

    private func presentProfileEdit() {
        coordinator?.showProfileEdit(
            nickname: viewModel.profile.nickname,
            profileImageName: viewModel.profile.profileImageName
        ) { [weak self] nickname, profileImageName in
            self?.viewModel.setProfile(nickname: nickname, profileImageName: profileImageName)
            self?.reloadContent()
        }
    }

    private func presentLocationSharingSelection() {
        coordinator?.showLocationSharingSelection(
            selectedOption: viewModel.profile.locationSharingOption
        ) { [weak self] option in
            self?.viewModel.setLocationSharingOption(option)
            self?.locationSharingRow.value = option.title
        }
    }

    private func presentLocationPermission() {
        coordinator?.showLocationPermission()
    }

    private func presentAppointmentNotificationList() {
        coordinator?.showAppointmentNotificationList(
            fetchItems: { [weak self] in self?.viewModel.appointmentNotifications ?? [] },
            onToggle: { [weak self] id in self?.viewModel.toggleNotification(id: id) }
        )
    }

}
