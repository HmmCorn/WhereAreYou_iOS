//
//  AppleLoginButton.swift
//  WhereAreYou
//
//  Created by 김성훈 on 8/21/26.
//

import UIKit
import AuthenticationServices

/// Apple 로그인 버튼 — HIG 표준 컴포넌트를 감싸는 얇은 래퍼
final class AppleLoginButton: UIView {

    var onTap: (() -> Void)?

    private lazy var button: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setUpLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpLayout() {
        addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @objc private func buttonTapped() {
        onTap?()
    }

}
