//
//  KakaoPlaceResponse.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/29/26.
//

import Foundation

/// 카카오 키워드/카테고리 검색 공통 응답
struct KakaoPlaceResponse: Decodable {
    let documents: [KakaoPlaceDocument]
}

/// 카카오 검색 결과 문서
struct KakaoPlaceDocument: Decodable {
    let id: String
    let placeName: String
    let categoryGroupCode: String
    let categoryName: String
    let addressName: String
    let roadAddressName: String
    let x: String
    let y: String

    enum CodingKeys: String, CodingKey {
        case id
        case placeName = "place_name"
        case categoryGroupCode = "category_group_code"
        case categoryName = "category_name"
        case addressName = "address_name"
        case roadAddressName = "road_address_name"
        case x
        case y
    }
}

extension KakaoPlaceDocument {

    /// Place로 변환, 좌표 파싱 실패 시 nil
    func toPlace() -> Place? {
        guard let longitude = Double(x), let latitude = Double(y) else {
            return nil
        }
        let address = roadAddressName.isEmpty ? addressName : roadAddressName
        return Place(
            id: id,
            name: placeName,
            address: address,
            coordinate: Coordinate(latitude: latitude, longitude: longitude),
            type: placeType
        )
    }

    /// category_group_code, category_name 기반 PlaceType 매핑
    private var placeType: PlaceType {
        switch categoryGroupCode {
        case "SW8":
            return .subway
        case "FD6":
            return .restaurant
        case "CE7":
            return .cafe
        case "HP8":
            return .hospital
        case "MT1", "CS2":
            return .shop
        default:
            return categoryName.contains("기차역") ? .station : .other
        }
    }
}
