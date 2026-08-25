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
        return true
    }

    private func configureFirebaseEmulators() {
        #if DEBUG
        Auth.auth().useEmulator(withHost: "localhost", port: 9099)
        let firestoreSettings = Firestore.firestore().settings
        firestoreSettings.host = "localhost:8080"
        firestoreSettings.isSSLEnabled = false
        firestoreSettings.cacheSettings = MemoryCacheSettings()
        Firestore.firestore().settings = firestoreSettings
        Database.database().useEmulator(withHost: "localhost", port: 9000)
        Storage.storage().useEmulator(withHost: "localhost", port: 9199)
        #endif
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) { }

}

