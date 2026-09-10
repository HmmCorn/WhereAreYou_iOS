//
//  SceneDelegate.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-07.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        let authRepository: AuthRepository = DIContainer.shared.resolve()
        if let userID = authRepository.currentUserID {
            window?.rootViewController = makeRootTabBarController()
            window?.makeKeyAndVisible()
            validateUser(userID: userID)
        } else {
            window?.rootViewController = makeRootLoginViewController()
            window?.makeKeyAndVisible()
        }
    }

    // MARK: - 자동 로그인 검증

    private func validateUser(userID: String) {
        let userRepository: UserRepository = DIContainer.shared.resolve()
        Task { @MainActor in
            do {
                _ = try await userRepository.fetchUser(userID: userID)
            } catch AppError.network {
                showNetworkErrorAlert { [weak self] in
                    self?.validateUser(userID: userID)
                }
            } catch {
                switchToLogin()
            }
        }
    }

    private func showNetworkErrorAlert(retryHandler: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "연결 오류",
            message: "네트워크 연결을 확인 후 다시 시도해 주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "재시도", style: .default) { _ in
            retryHandler()
        })
        alert.addAction(UIAlertAction(title: "로그아웃", style: .destructive) { [weak self] _ in
            self?.switchToLogin()
        })
        window?.rootViewController?.present(alert, animated: true)
    }

    // MARK: - 로그인 화면 생성

    private func makeRootLoginViewController() -> UIViewController {
        let signInService: SignInService = DIContainer.shared.resolve()
        let authRepository: AuthRepository = DIContainer.shared.resolve()
        let userRepository: UserRepository = DIContainer.shared.resolve()
        let useCase = SignInUseCase(
            signInService: signInService,
            authRepository: authRepository,
            userRepository: userRepository
        )
        let viewModel = LoginViewModel(signInUseCase: useCase)
        let loginViewController = LoginViewController(viewModel: viewModel)
        loginViewController.onLoginSuccess = { [weak self] _ in
            self?.switchToHome()
        }
        return loginViewController
    }

    // MARK: - 마이페이지 화면 생성

    private func makeMyPageViewController() -> MyPageViewController {
        let authRepository: AuthRepository = DIContainer.shared.resolve()
        let viewModel = MyPageViewModel(
            observeLocationPermissionUseCase: ObserveLocationPermissionUseCase(
                repository: DIContainer.shared.resolve(LocationPermissionRepository.self)
            ),
            signOutUseCase: SignOutUseCase(authRepository: authRepository)
        )
        let myPageViewController = MyPageViewController(viewModel: viewModel)
        myPageViewController.onSignOut = { [weak self] in
            self?.switchToLogin()
        }
        return myPageViewController
    }

    // MARK: - 화면 전환

    private func switchToHome() {
        guard let window else { return }
        let tabBarController = makeRootTabBarController()

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            window.rootViewController = tabBarController
        }
    }

    private func switchToLogin() {
        guard let window else { return }
        let loginViewController = makeRootLoginViewController()

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            window.rootViewController = loginViewController
        }
    }

    private func makeRootTabBarController() -> UITabBarController {
        let homeNav = UINavigationController(rootViewController: HomeViewController())
        homeNav.tabBarItem = UITabBarItem(
            title: "홈",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        let listNav = UINavigationController(rootViewController: AppointmentListViewController())
        listNav.tabBarItem = UITabBarItem(
            title: "약속",
            image: UIImage(systemName: "tray.full"),
            selectedImage: UIImage(systemName: "tray.full.fill")
        )

        let myPageViewController = makeMyPageViewController()
        let myPageNav = UINavigationController(rootViewController: myPageViewController)
        myPageNav.tabBarItem = UITabBarItem(
            title: "마이페이지",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [homeNav, listNav, myPageNav]
        tabBarController.tabBar.tintColor = .blue1
        return tabBarController
    }

    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) { }

}
