//
//  SceneDelegate.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-07.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let coordinator = AppCoordinator(window: window)
        appCoordinator = coordinator
        coordinator.start()

        if let url = connectionOptions.urlContexts.first?.url {
            handle(url: url)
        }
    }

    /// 라이브 액티비티 탭·버튼으로 앱이 이미 떠 있는 상태에서 들어온 링크
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        handle(url: url)
    }

    private func handle(url: URL) {
        guard let deepLink = AppointmentDeepLink(url: url) else { return }
        appCoordinator?.handle(deepLink: deepLink)
    }

    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) {
        appCoordinator?.registerNotificationIfAuthorized()
    }

    func sceneDidEnterBackground(_ scene: UIScene) { }

}
