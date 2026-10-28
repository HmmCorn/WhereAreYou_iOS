//
//  AppointmentDTO.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-10-29.
//

import Foundation

/// 약속 callable 응답을 Domain Appointment로 변환하는 DTO.
/// 시간은 epoch 밀리초, 참여자는 공개 프로필 필드만 담겨 온다
struct AppointmentDTO {

    let id: String
    let code: String
    let name: String
    let dateTime: Date
    let place: Place?
    let participants: [User]

    init?(data: Any) {
        guard let data = data as? [String: Any],
              let id = data["id"] as? String,
              let code = data["code"] as? String,
              let name = data["name"] as? String,
              let dateTimeMillis = data["dateTime"] as? Double else {
            return nil
        }
        self.id = id
        self.code = code
        self.name = name
        self.dateTime = Date(timeIntervalSince1970: dateTimeMillis / 1000)
        self.place = (data["place"] as? [String: Any]).flatMap(Self.place(from:))
        self.participants = (data["participants"] as? [[String: Any]] ?? []).compactMap { userData in
            guard let userID = userData["id"] as? String else { return nil }
            return UserDTO(data: userData)?.toDomain(id: userID)
        }
    }

    func toDomain() -> Appointment {
        Appointment(
            id: id,
            code: code,
            name: name,
            dateTime: dateTime,
            place: place,
            participants: participants
        )
    }

    /// 장소를 Firestore 임베딩 형식으로 바꾼다 — callable 요청과 이후 문서 저장에 같이 쓴다
    static func data(from place: Place) -> [String: Any] {
        [
            "id": place.id,
            "name": place.name,
            "address": place.address,
            "coordinate": [
                "latitude": place.coordinate.latitude,
                "longitude": place.coordinate.longitude
            ],
            "type": placeTypeValue(place.type)
        ]
    }

    private static func place(from data: [String: Any]) -> Place? {
        guard let id = data["id"] as? String,
              let name = data["name"] as? String,
              let address = data["address"] as? String,
              let coordinate = data["coordinate"] as? [String: Any],
              let latitude = coordinate["latitude"] as? Double,
              let longitude = coordinate["longitude"] as? Double else {
            return nil
        }
        return Place(
            id: id,
            name: name,
            address: address,
            coordinate: Coordinate(latitude: latitude, longitude: longitude),
            type: placeType(from: data["type"] as? String)
        )
    }

    private static func placeTypeValue(_ type: PlaceType) -> String {
        switch type {
        case .subway: return "SUBWAY"
        case .restaurant: return "RESTAURANT"
        case .cafe: return "CAFE"
        case .hospital: return "HOSPITAL"
        case .station: return "STATION"
        case .shop: return "SHOP"
        case .other: return "OTHER"
        }
    }

    private static func placeType(from value: String?) -> PlaceType {
        PlaceType.allCases.first { placeTypeValue($0) == value } ?? .other
    }

}
