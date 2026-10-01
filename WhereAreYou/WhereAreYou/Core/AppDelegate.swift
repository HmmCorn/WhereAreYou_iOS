//
//  AppDelegate.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-07.
//

import UIKit
import NMapsMap
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase
import FirebaseStorage
import FirebaseMessaging
import UserNotifications
import AppIntents

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let clientId = Bundle.main.object(forInfoDictionaryKey: "NMFClientId") as? String {
            NMFAuthManager.shared().ncpKeyId = clientId
        }
        FirebaseApp.configure()
        clearKeychainOnReinstall()
        configureFirebaseEmulators()
        DIContainer.shared.registerDependencies()
        registerAppIntentDependencies()

        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self

        return true
    }

    /// 라이브 액티비티 버튼 같은 App Intent가 @AppDependency로 받을 의존성을 등록한다.
    /// 인텐트는 앱이 실행된 직후 이 등록을 거쳐 실행되므로, DI 컨테이너를 직접 알 필요가 없다
    private func registerAppIntentDependencies() {
        let routeProgressService: RouteProgressService = DIContainer.shared.resolve()
        AppDependencyManager.shared.add(dependency: routeProgressService)
    }

    /// 앱 재설치 시 Keychain에 남은 Firebase Auth 인증 정보를 제거
    private func clearKeychainOnReinstall() {
        let hasLaunchedKey = "hasLaunchedBefore"
        if !UserDefaults.standard.bool(forKey: hasLaunchedKey) {
            try? Auth.auth().signOut()
            UserDefaults.standard.set(true, forKey: hasLaunchedKey)
        }
    }

    private static var emulatorHost: String {
        ProcessInfo.processInfo.environment["FIREBASE_EMULATOR_HOST"] ?? "localhost"
    }

    private func configureFirebaseEmulators() {
        #if DEBUG
        let host = Self.emulatorHost
        let firestoreSettings = Firestore.firestore().settings
        firestoreSettings.host = "\(host):8080"
        firestoreSettings.isSSLEnabled = false
        firestoreSettings.cacheSettings = MemoryCacheSettings()
        Firestore.firestore().settings = firestoreSettings
        Database.database().useEmulator(withHost: host, port: 9000)
        #endif
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) { }

    // MARK: - APNs 토큰

    /// APNs 서버에 디바이스 등록이 성공했을 때 시스템이 호출
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        // 이미 등록된 상태에서 불러도 대리자 didReceiveRegistration이 기존 설치 ID로 다시 호출된다.
        // APNs 등록은 앱 실행·로그인 때마다 일어나므로, 여기서 등록을 요청해 그때마다 설치 ID를 저장한다
        Messaging.messaging().register { _ in }
    }

    // MARK: - FCM 설치 ID 저장

    private func saveFCMInstallationID(_ installationID: String) {
        let fcmInstallationIDService: FCMInstallationIDService = DIContainer.shared.resolve()
        Task {
            try? await fcmInstallationIDService.save(installationID: installationID)
        }
    }

}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {

    /// 앱이 포그라운드일 때 알림이 도착하면 호출 — 표시 방식을 결정
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

}

// MARK: - MessagingDelegate

extension AppDelegate: MessagingDelegate {

    /// FCM 등록이 생성·갱신되거나 register(completion:)을 직접 호출했을 때 호출 — 설치 ID를 서버 발송 대상으로 저장
    func messaging(_ messaging: Messaging, didReceiveRegistration installationId: String?) {
        guard let installationID = installationId else { return }
        saveFCMInstallationID(installationID)
    }

}
