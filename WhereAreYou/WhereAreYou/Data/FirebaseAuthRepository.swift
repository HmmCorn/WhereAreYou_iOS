//
//  FirebaseAuthRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-03.
//

import Foundation
import FirebaseAuth

/// AuthRepository의 Firebase Auth 구현체
final class FirebaseAuthRepository: AuthRepository {

    var currentUserID: String? {
        Auth.auth().currentUser?.uid
    }

    func signIn(idToken: String, nonce: String) async throws -> String {
        let credential = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: nonce,
            fullName: nil
        )
        do {
            let authResult = try await Auth.auth().signIn(with: credential)
            return authResult.user.uid
        } catch {
            throw FirebaseErrorMapper.map(error)
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

}
