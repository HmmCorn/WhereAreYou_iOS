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
    private let screenFactory: AppScreenFactory
    private var tabBarCoordinator: TabBarCoordinator?

    init(window: UIWindow, screenFactory: ScreenFactory = .shared) {
        self.window = window
        self.screenFactory = screenFactory
    }

    func start() {
        window.rootViewController = makeLoginViewController()
        window.makeKeyAndVisible()
    }

    private func makeLoginViewController() -> UIViewController {
        let loginViewController = screenFactory.makeLoginViewController()
        loginViewController.onAppleLoginTap = { [weak self] in
            self?.switchToHome()
        }
        return loginViewController
    }

    private func switchToHome() {
        let coordinator = TabBarCoordinator()
        tabBarCoordinator = coordinator
        coordinator.start()

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            self.window.rootViewController = coordinator.tabBarController
        }
    }

}
