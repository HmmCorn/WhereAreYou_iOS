//
//  LoginViewController.swift
//  WhereAreYou
//
//  Created by 김성훈 on 8/21/26.
//

import UIKit

/// 로그인 화면 — 앱 진입 시 최초로 표시되는 화면
final class LoginViewController: UIViewController {

    // MARK: - Properties

    var onAppleLoginTap: (() -> Void)?

    // MARK: - Init

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: .loginBackground)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: .logo)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "어딘데"
        label.font = .boldPreferredFont(forTextStyle: .title1)
        label.textColor = .blue1
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "약속 장소로 가는 길, 함께 확인해요"
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let appleLoginButton: AppleLoginButton = AppleLoginButton()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpLayout()
        setUpActions()
    }

    // MARK: - Set Up

    private func setUpView() {
        view.backgroundColor = .pointBackground
    }

    private func setUpLayout() {
        view.addSubview(backgroundImageView)
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(appleLoginButton)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -240),
            logoImageView.widthAnchor.constraint(equalToConstant: 119),
            logoImageView.heightAnchor.constraint(equalToConstant: 74),

            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),

            appleLoginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            appleLoginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            appleLoginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            appleLoginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setUpActions() {
        appleLoginButton.onTap = { [weak self] in
            // TODO: Apple 로그인 인증 로직 연결 필요
            self?.onAppleLoginTap?()
        }
    }

}
