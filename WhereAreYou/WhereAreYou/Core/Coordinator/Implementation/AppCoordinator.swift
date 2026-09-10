//
//  AppCoordinator.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

import UIKit

/// 로그인 화면 표시, 로그인 성공 시 탭바로 전환 등 앱 최상위 화면전환을 담당
final class AppCoordinator: Coordinator {

    private let window: UIWindow
    private let screenFactory: ScreenFactory
    private var tabBarCoordinator: TabBarCoordinator?

    init(window: UIWindow, screenFactory: ScreenFactory = .shared) {
        self.window = window
        self.screenFactory = screenFactory
    }

    func start() {
        let authRepository: AuthRepository = screenFactory.container.resolve()
        if authRepository.currentUserID != nil {
            showHome()
            validateUser()
        } else {
            showLogin()
        }
        window.makeKeyAndVisible()
    }

    // MARK: - 자동 로그인 검증

    private func validateUser() {
        let authRepository: AuthRepository = screenFactory.container.resolve()
        let userRepository: UserRepository = screenFactory.container.resolve()
        guard let userID = authRepository.currentUserID else {
            switchToLogin()
            return
        }
        Task { @MainActor in
            do {
                _ = try await userRepository.fetchUser(userID: userID)
            } catch AppError.network {
                self.showNetworkErrorAlert()
            } catch {
                self.switchToLogin()
            }
        }
    }

    private func showNetworkErrorAlert() {
        let alert = UIAlertController(
            title: "연결 오류",
            message: "네트워크 연결을 확인 후 다시 시도해 주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "재시도", style: .default) { [weak self] _ in
            self?.validateUser()
        })
        alert.addAction(UIAlertAction(title: "로그아웃", style: .destructive) { [weak self] _ in
            self?.switchToLogin()
        })
        window.rootViewController?.present(alert, animated: true)
    }

    // MARK: - 초기 화면 설정

    private func showLogin() {
        window.rootViewController = makeLoginViewController()
    }

    private func showHome() {
        let coordinator = TabBarCoordinator()
        tabBarCoordinator = coordinator
        coordinator.onSignOut = { [weak self] in
            self?.switchToLogin()
        }
        coordinator.start()
        window.rootViewController = coordinator.tabBarController
    }

    // MARK: - 화면 전환

    private func switchToHome() {
        let coordinator = TabBarCoordinator()
        tabBarCoordinator = coordinator
        coordinator.onSignOut = { [weak self] in
            self?.switchToLogin()
        }
        coordinator.start()

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            self.window.rootViewController = coordinator.tabBarController
        }
    }

    private func switchToLogin() {
        tabBarCoordinator = nil
        let loginViewController = makeLoginViewController()

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            self.window.rootViewController = loginViewController
        }
    }

    private func makeLoginViewController() -> LoginViewController {
        let loginViewController = screenFactory.makeLoginViewController()
        loginViewController.onLoginSuccess = { [weak self] _ in
            self?.switchToHome()
        }
        return loginViewController
    }

}
