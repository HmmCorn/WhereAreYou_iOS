//
//  FirestoreFCMInstallationIDRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-19.
//

import Foundation
import FirebaseFirestore

/// FCMInstallationIDRepository의 Firestore 구현체
final class FirestoreFCMInstallationIDRepository: FCMInstallationIDRepository {

    private let db = Firestore.firestore()

    func save(installationID: String, forUserID userID: String) async throws {
        do {
            try await db.collection("users").document(userID)
                .updateData(["fcmInstallationID": installationID])
        } catch {
            throw FirebaseErrorMapper.map(error)
        }
    }

    func delete(forUserID userID: String) async throws {
        do {
            try await db.collection("users").document(userID)
                .updateData(["fcmInstallationID": FieldValue.delete()])
        } catch {
            throw FirebaseErrorMapper.map(error)
        }
    }

}
