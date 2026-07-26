//
//  LocationPermissionViewController.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/25/26.
//

import Combine
import UIKit

final class LocationPermissionViewController: UIViewController {

    private let viewModel: MyPageViewModel
    private var cancellables = Set<AnyCancellable>()

    private let card = MyPageCardView()

    private let statusIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let statusTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldPreferredFont(forTextStyle: .title2)
        label.textAlignment = .center
        return label
    }()

    private let statusDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var openSettingsButton = UIButton.filled(
        title: "설정으로 이동",
        background: .blue1,
        tint: .white,
        font: .body
    )

    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init(viewModel:)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "위치 권한 설정"
        view.backgroundColor = .systemBackground
        setUpLayout()
        setUpActions()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setUpLayout() {
        [statusIcon, statusTitleLabel, statusDescriptionLabel, openSettingsButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let statusStack = UIStackView(arrangedSubviews: [statusIcon, statusTitleLabel, statusDescriptionLabel])
        statusStack.axis = .vertical
        statusStack.spacing = 12
        statusStack.alignment = .center
        statusStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(statusStack)
        view.addSubview(openSettingsButton)

        NSLayoutConstraint.activate([
            statusIcon.widthAnchor.constraint(equalToConstant: 48),
            statusIcon.heightAnchor.constraint(equalToConstant: 48),

            statusStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            statusStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            statusStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            openSettingsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            openSettingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            openSettingsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            openSettingsButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setUpActions() {
        openSettingsButton.addAction(UIAction { [weak self] _ in
            self?.handleButtonTap()
        }, for: .touchUpInside)
    }

    private func bindViewModel() {
        viewModel.$locationPermissionState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.reloadContent(with: state)
            }
            .store(in: &cancellables)
    }

    private func handleButtonTap() {
        guard viewModel.handlePermissionAction() == .shouldOpenSettings else { return }
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
    }

    private func reloadContent(with state: LocationPermissionState) {
        statusTitleLabel.text = state.title
        statusDescriptionLabel.text = state.description
        statusIcon.image = UIImage(systemName: state.iconName)
        statusIcon.tintColor = state.isGranted ? .blue2 : .customRed

        var config = openSettingsButton.configuration
        config?.attributedTitle = AttributedString(
            state == .notDetermined ? "위치 권한 요청하기" : "설정으로 이동",
            attributes: AttributeContainer([.font: UIFont.preferredFont(forTextStyle: .body)])
        )
        openSettingsButton.configuration = config
    }

}
