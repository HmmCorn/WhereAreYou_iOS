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

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    private var latestFCMToken: String?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let clientId = Bundle.main.object(forInfoDictionaryKey: "NMFClientId") as? String {
            NMFAuthManager.shared().ncpKeyId = clientId
        }
        FirebaseApp.configure()
        clearKeychainOnReinstall()
        configureFirebaseEmulators()
        DIContainer.shared.registerDependencies()

        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self

        return true
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

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        if let token = latestFCMToken {
            saveFCMToken(token)
        }
    }

    // MARK: - FCM 토큰 저장

    private func saveFCMToken(_ token: String) {
        let authRepository: AuthRepository = DIContainer.shared.resolve()
        guard let userID = authRepository.currentUserID else { return }

        let fcmTokenRepository: FCMTokenRepository = DIContainer.shared.resolve()
        Task {
            try? await fcmTokenRepository.save(token: token, forUserID: userID)
        }
    }

}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {

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

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        latestFCMToken = token
        saveFCMToken(token)
    }

}
