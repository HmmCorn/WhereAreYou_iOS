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

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let clientId = Bundle.main.object(forInfoDictionaryKey: "NMFClientId") as? String {
            NMFAuthManager.shared().ncpKeyId = clientId
        }
        FirebaseApp.configure()
        configureFirebaseEmulators()
        DIContainer.shared.registerDependencies()
        return true
    }

    // 로컬 네트워크 IP — 기기마다 다르므로 본인의 IP로 변경하여 사용 (터미널: ipconfig getifaddr en0)
    private static let emulatorHost = "192.168.45.234"

    private func configureFirebaseEmulators() {
        #if DEBUG
        let host = Self.emulatorHost
        let firestoreSettings = Firestore.firestore().settings
        firestoreSettings.host = "\(host):8080"
        firestoreSettings.isSSLEnabled = false
        firestoreSettings.cacheSettings = MemoryCacheSettings()
        Firestore.firestore().settings = firestoreSettings
        Database.database().useEmulator(withHost: host, port: 9000)
        Storage.storage().useEmulator(withHost: host, port: 9199)
        #endif
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) { }

}

