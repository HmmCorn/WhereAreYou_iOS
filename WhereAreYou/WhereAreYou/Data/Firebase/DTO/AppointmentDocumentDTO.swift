//
//  AppointmentDocumentDTO.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-11-07.
//

import Foundation
import FirebaseFirestore

/// Firestore appointments 문서를 Domain Appointment로 변환하는 DTO.
/// 문서에는 참여자 ID만 있어, 참여자 프로필은 저장소가 조회해 변환할 때 넘겨준다
struct AppointmentDocumentDTO {

    let id: String
    let code: String
    let name: String
    let dateTime: Date
    let place: Place?
    let participantIDs: [String]

    init?(id: String, data: [String: Any]) {
        guard let code = data["code"] as? String,
              let name = data["name"] as? String,
              let dateTime = data["dateTime"] as? Timestamp else {
            return nil
        }
        self.id = id
        self.code = code
        self.name = name
        self.dateTime = dateTime.dateValue()
        self.place = (data["place"] as? [String: Any]).flatMap(AppointmentDTO.place(from:))
        self.participantIDs = data["participantIDs"] as? [String] ?? []
    }

    /// 프로필을 찾지 못한 참여자는 제외한다
    func toDomain(usersByID: [String: User]) -> Appointment {
        Appointment(
            id: id,
            code: code,
            name: name,
            dateTime: dateTime,
            place: place,
            participants: participantIDs.compactMap { usersByID[$0] }
        )
    }

}
