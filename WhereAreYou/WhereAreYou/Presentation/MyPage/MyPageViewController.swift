//
//  MyPageViewController.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/25/26.
//

import UIKit
import Combine

final class MyPageViewController: UIViewController {

    private static let cardSpacing: CGFloat = 16

    private let viewModel: MyPageViewModel
    weak var coordinator: MyPageCoordinating?
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init(viewModel:)")
    }

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
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
        icon: nil,
        title: "닉네임",
        isCircularImage: true,
        accessoryView: profileEditIcon
    )

    // MARK: - 위치 카드

    private let locationCard = MyPageCardView()
    private let locationSharingRow = MyPageRow(icon: UIImage(systemName: "location"), title: "위치 공유 설정")
    private let locationPermissionRow = MyPageRow(icon: UIImage(systemName: "location.circle"), title: "위치 권한 설정")
    private let liveActivityPermissionRow = MyPageRow(
        icon: UIImage(systemName: "clock.badge"),
        title: "실시간 현황 설정"
    )

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
    private let signOutRow = MyPageRow(icon: UIImage(systemName: "rectangle.portrait.and.arrow.right"), title: "로그아웃")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpLayout()
        setUpStaticContent()
        setUpActions()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.loadProfile()
        viewModel.loadAppointmentNotifications()
    }

    private func setUpLayout() {
        logoImageView.setAppAsset(.logo)

        [logoImageView, titleLabel, scrollView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        setUpCard(profileCard, rows: [profileRow])
        setUpCard(locationCard, rows: [locationSharingRow, locationPermissionRow, liveActivityPermissionRow])
        setUpCard(notificationCard, rows: [notificationRow, appointmentNotificationRow])
        setUpCard(etcCard, rows: [appInfoRow, signOutRow])

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
        // 실시간 현황은 앱에서 요청할 수 없어 설정 앱의 앱 설정 화면으로 바로 보낸다
        liveActivityPermissionRow.onTap = {
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingsURL)
        }
        appointmentNotificationRow.onTap = { [weak self] in
            self?.presentAppointmentNotificationList()
        }
        appInfoRow.onTap = {
            print("앱 정보 탭")
        }
        signOutRow.onTap = { [weak self] in
            self?.confirmSignOut()
        }

        notificationSwitch.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            viewModel.saveNotificationEnabled(notificationSwitch.isOn)
        }, for: .valueChanged)
    }

    private func setUpStaticContent() {
        appInfoRow.value = "버전 정보"
        signOutRow.value = "현재 계정에서 나가기"
    }

    /// 내 정보를 아직 불러오지 못했으면 값을 비우고 스위치를 끈다
    private func updateProfileRows(_ profile: MyPageProfile?) {
        profileRow.value = profile?.nickname
        if let profile {
            profileRow.setProfileIcon(profile.profileImageName)
        }
        locationSharingRow.value = profile?.locationSharingOption.title
        notificationSwitch.isEnabled = profile != nil
        notificationSwitch.setOn(profile?.isNotificationEnabled ?? false, animated: true)
        notificationRow.value = profile.map { $0.isNotificationEnabled ? "전체 알림 켜짐" : "전체 알림 꺼짐" }
    }

    private func updateAppointmentNotificationRow(items: [AppointmentListItem]) {
        let enabledCount = items.filter { $0.isNotificationEnabled }.count
        appointmentNotificationRow.value = "\(enabledCount)개의 약속 알림 켜짐"
    }

    private func presentProfileEdit() {
        guard let profile = viewModel.profile else { return }
        coordinator?.showProfileEdit(
            nickname: profile.nickname,
            profileImageName: profile.profileImageName
        ) { [weak self] nickname, profileImageName in
            self?.viewModel.saveProfile(nickname: nickname, profileImageName: profileImageName)
        }
    }

    private func presentLocationSharingSelection() {
        guard let profile = viewModel.profile else { return }
        coordinator?.showLocationSharingSelection(
            selectedOption: profile.locationSharingOption
        ) { [weak self] option in
            self?.viewModel.saveLocationSharingOption(option)
        }
    }

    private func presentLocationPermission() {
        coordinator?.showLocationPermission()
    }

    private func bindViewModel() {
        viewModel.$profile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                self?.updateProfileRows(profile)
            }
            .store(in: &cancellables)

        viewModel.$profileSaveError
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.handleProfileSaveError(error)
            }
            .store(in: &cancellables)

        viewModel.$appointmentNotifications
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.updateAppointmentNotificationRow(items: items)
            }
            .store(in: &cancellables)

        viewModel.$locationPermissionState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.locationPermissionRow.value = state.title
            }
            .store(in: &cancellables)

        viewModel.$liveActivityPermissionState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.liveActivityPermissionRow.value = state.title
            }
            .store(in: &cancellables)

        viewModel.$signOutResult
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .success:
                    self?.coordinator?.signOut()
                case .failure(let error):
                    self?.showSignOutError(error)
                }
            }
            .store(in: &cancellables)
    }

    private func confirmSignOut() {
        let alert = UIAlertController(title: "로그아웃", message: "정말 로그아웃하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "로그아웃", style: .destructive) { [weak self] _ in
            self?.viewModel.signOut()
        })
        present(alert, animated: true)
    }

    private func showSignOutError(_ error: Error) {
        let alert = UIAlertController(
            title: "로그아웃 실패",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    /// 위치 공유 설정 화면에 있는 동안 실패하면 되돌아간 값을 볼 수 있게 마이페이지로 돌아온 뒤 알럿을 띄운다
    private func handleProfileSaveError(_ error: Error) {
        guard let navigationController,
              navigationController.topViewController is LocationSharingSelectionViewController
        else {
            showProfileSaveError(error)
            return
        }

        navigationController.popToViewController(self, animated: true)
        if let transitionCoordinator = navigationController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: nil) { [weak self] _ in
                self?.showProfileSaveError(error)
            }
        } else {
            showProfileSaveError(error)
        }
    }

    private func showProfileSaveError(_ error: Error) {
        let alert = UIAlertController(
            title: "저장 실패",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        (navigationController ?? self).present(alert, animated: true)
    }

    private func presentAppointmentNotificationList() {
        coordinator?.showAppointmentNotificationList(
            fetchItems: { [weak self] in self?.viewModel.appointmentNotifications ?? [] },
            onToggle: { [weak self] id in self?.viewModel.toggleNotification(id: id) }
        )
    }

}
