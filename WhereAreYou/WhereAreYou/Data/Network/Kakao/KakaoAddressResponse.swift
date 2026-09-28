//
//  KakaoAddressResponse.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/29/26.
//

import Foundation

/// 카카오 좌표 -> 주소 변환 응답
struct KakaoAddressResponse: Decodable {
    let documents: [KakaoAddressDocument]
}

/// 카카오 좌표 -> 주소 변환 결과 문서
struct KakaoAddressDocument: Decodable {
    let roadAddress: KakaoRoadAddress?
    let address: KakaoAddress?

    enum CodingKeys: String, CodingKey {
        case roadAddress = "road_address"
        case address
    }
}

/// 도로명주소
struct KakaoRoadAddress: Decodable {
    let addressName: String

    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
    }
}

/// 지번주소
struct KakaoAddress: Decodable {
    let addressName: String

    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
    }
}

extension KakaoAddressResponse {

    /// Place로 변환, 도로명 우선 없으면 지번, 결과 없으면 notFound
    func toPlace(coordinate: Coordinate) throws -> Place {
        guard let document = documents.first else {
            throw AppError.notFound
        }
        guard let address = document.roadAddress?.addressName ?? document.address?.addressName else {
            throw AppError.notFound
        }
        return Place(
            id: "address_\(coordinate.latitude)_\(coordinate.longitude)",
            name: address,
            address: address,
            coordinate: coordinate,
            type: .other
        )
    }
}
