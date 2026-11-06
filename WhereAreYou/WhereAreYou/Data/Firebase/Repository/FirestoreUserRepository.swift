//
//  FirestoreUserRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-03.
//

import Foundation
import FirebaseFirestore

/// UserRepository의 Firestore 구현체
final class FirestoreUserRepository: UserRepository {

    /// Firestore `in` 질의 한 번에 넣을 수 있는 값 개수
    private static let inQueryLimit = 30

    private let db = Firestore.firestore()

    func createUserIfNeeded(userID: String, nickname: String) async throws -> User {
        let docRef = db.collection("users").document(userID)

        do {
            let result = try await db.runTransaction { transaction, errorPointer in
                let snapshot: DocumentSnapshot
                do {
                    snapshot = try transaction.getDocument(docRef)
                } catch {
                    errorPointer?.pointee = error as NSError
                    return nil
                }

                if let data = snapshot.data(), snapshot.exists,
                   let dto = UserDTO(data: data) {
                    return dto.toDomain(id: userID)
                }

                let userData: [String: Any] = [
                    "nickname": nickname,
                    "profileImage": "basic",
                    "defaultTransportMode": "TRANSIT",
                    "locationSharingScope": "ONLY_DURING_APPOINTMENT",
                    "isNotificationEnabled": true,
                    "appointmentsNotification": [String: Bool](),
                    "createdAt": FieldValue.serverTimestamp()
                ]

                transaction.setData(userData, forDocument: docRef)

                return User(
                    id: userID,
                    nickname: nickname,
                    profileImage: "basic",
                    defaultTransportMode: .transit,
                    locationSharingScope: .onlyDuringAppointment,
                    isNotificationEnabled: true,
                    appointmentsNotification: [:]
                )
            }

            guard let user = result as? User else {
                throw AppError.notFound
            }
            return user
        } catch let error as AppError {
            throw error
        } catch {
            throw FirebaseErrorMapper.map(error)
        }
    }

    func fetchUser(userID: String) async throws -> User {
        do {
            let snapshot = try await db.collection("users").document(userID).getDocument()

            guard let data = snapshot.data(), snapshot.exists,
                  let dto = UserDTO(data: data) else {
                throw AppError.notFound
            }
            return dto.toDomain(id: userID)
        } catch let error as AppError {
            throw error
        } catch {
            throw FirebaseErrorMapper.map(error)
        }
    }

    func fetchUsers(userIDs: Set<String>) async throws -> [String: User] {
        let userIDs = Array(userIDs)
        var usersByID: [String: User] = [:]

        do {
            for start in stride(from: 0, to: userIDs.count, by: Self.inQueryLimit) {
                let chunk = Array(userIDs[start..<min(start + Self.inQueryLimit, userIDs.count)])
                let snapshot = try await db.collection("users")
                    .whereField(FieldPath.documentID(), in: chunk)
                    .getDocuments()
                for document in snapshot.documents {
                    usersByID[document.documentID] = UserDTO(data: document.data())?.toDomain(id: document.documentID)
                }
            }
            return usersByID
        } catch {
            throw FirebaseErrorMapper.map(error)
        }
    }

}
