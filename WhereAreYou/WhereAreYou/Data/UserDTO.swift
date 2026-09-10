//
//  UserDTO.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-10.
//

import Foundation

/// Firestore users 문서를 Domain User로 변환하는 DTO
struct UserDTO {

    let nickname: String
    let profileImage: String
    let defaultTransportMode: String?
    let locationSharingScope: String?
    let isNotificationEnabled: Bool
    let appointmentsNotification: [String: Bool]

    init?(data: [String: Any]) {
        guard let nickname = data["nickname"] as? String,
              let profileImage = data["profileImage"] as? String else {
            return nil
        }
        self.nickname = nickname
        self.profileImage = profileImage
        self.defaultTransportMode = data["defaultTransportMode"] as? String
        self.locationSharingScope = data["locationSharingScope"] as? String
        self.isNotificationEnabled = data["isNotificationEnabled"] as? Bool ?? true
        self.appointmentsNotification = data["appointmentsNotification"] as? [String: Bool] ?? [:]
    }

    func toDomain(id: String) -> User {
        let transportMode: TransportType = {
            switch defaultTransportMode {
            case "WALK": return .walk
            case "CAR": return .car
            default: return .transit
            }
        }()

        let sharingScope: LocationSharingScope = {
            switch locationSharingScope {
            case "ALWAYS": return .always
            case "NEVER": return .never
            default: return .onlyDuringAppointment
            }
        }()

        return User(
            id: id,
            nickname: nickname,
            // TODO: Firebase Storage 전환 시 실제 URL로 교체
            profileImage: URL(string: profileImage)!,
            defaultTransportMode: transportMode,
            locationSharingScope: sharingScope,
            isNotificationEnabled: isNotificationEnabled,
            appointmentsNotification: appointmentsNotification
        )
    }

}
