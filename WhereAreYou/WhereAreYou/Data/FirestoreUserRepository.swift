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
                   let user = self.makeUser(id: userID, data: data) {
                    return user
                }

                let userData: [String: Any] = [
                    "nickname": nickname,
                    // TODO: Firebase Storage 전환 시 실제 URL로 교체
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
                    // TODO: Firebase Storage 전환 시 실제 URL로 교체
                    profileImage: URL(string: "basic")!,
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
                  let user = makeUser(id: userID, data: data) else {
                throw AppError.notFound
            }
            return user
        } catch let error as AppError {
            throw error
        } catch {
            throw FirebaseErrorMapper.map(error)
        }
    }

    // MARK: - Firestore → User 변환

    private func makeUser(id: String, data: [String: Any]) -> User? {
        guard let nickname = data["nickname"] as? String,
              let profileImageString = data["profileImage"] as? String else {
            return nil
        }

        let transportMode: TransportType = {
            switch data["defaultTransportMode"] as? String {
            case "WALK": return .walk
            case "CAR": return .car
            default: return .transit
            }
        }()

        let sharingScope: LocationSharingScope = {
            switch data["locationSharingScope"] as? String {
            case "ALWAYS": return .always
            case "NEVER": return .never
            default: return .onlyDuringAppointment
            }
        }()

        return User(
            id: id,
            nickname: nickname,
            // TODO: Firebase Storage 전환 시 실제 URL로 교체
            profileImage: URL(string: profileImageString)!,
            defaultTransportMode: transportMode,
            locationSharingScope: sharingScope,
            isNotificationEnabled: data["isNotificationEnabled"] as? Bool ?? true,
            appointmentsNotification: data["appointmentsNotification"] as? [String: Bool] ?? [:]
        )
    }

}
