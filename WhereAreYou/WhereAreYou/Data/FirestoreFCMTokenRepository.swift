//
//  FirestoreFCMTokenRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-19.
//

import Foundation
import FirebaseFirestore

/// FCMTokenRepository의 Firestore 구현체
final class FirestoreFCMTokenRepository: FCMTokenRepository {

    private let db = Firestore.firestore()

    func save(token: String, forUserID userID: String) async throws {
        do {
            try await db.collection("users").document(userID)
                .updateData(["fcmToken": token])
        } catch {
            throw FirebaseErrorMapper.map(error)
        }
    }

    func delete(forUserID userID: String) async throws {
        do {
            try await db.collection("users").document(userID)
                .updateData(["fcmToken": FieldValue.delete()])
        } catch {
            throw FirebaseErrorMapper.map(error)
        }
    }

}
