//
//  SceneDelegate.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-07.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var homeCoordinator: HomeCoordinator?
    private var appointmentListCoordinator: AppointmentListCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = makeRootLoginViewController()
        window?.makeKeyAndVisible()
    }

    private func makeRootLoginViewController() -> UIViewController {
        let loginViewController = LoginViewController()
        loginViewController.onAppleLoginTap = { [weak self] in
            self?.switchToHome()
        }
        return loginViewController
    }

    private func switchToHome() {
        guard let window else { return }
        let tabBarController = makeRootTabBarController()

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            window.rootViewController = tabBarController
        }
    }

    private func makeRootTabBarController() -> UITabBarController {
        let homeNav = UINavigationController()
        homeCoordinator = HomeCoordinator(navigationController: homeNav)
        homeCoordinator?.start()
        homeNav.tabBarItem = UITabBarItem(
            title: "홈",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        let listNav = UINavigationController()
        appointmentListCoordinator = AppointmentListCoordinator(navigationController: listNav)
        appointmentListCoordinator?.start()
        listNav.tabBarItem = UITabBarItem(
            title: "약속",
            image: UIImage(systemName: "tray.full"),
            selectedImage: UIImage(systemName: "tray.full.fill")
        )

        let myPageNav = UINavigationController(rootViewController: MyPageViewController())
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
