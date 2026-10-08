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
    /// 시/도
    let region1DepthName: String?
    /// 시/군/구
    let region2DepthName: String?

    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
        case region1DepthName = "region_1depth_name"
        case region2DepthName = "region_2depth_name"
    }
}

/// 지번주소
struct KakaoAddress: Decodable {
    let addressName: String
    /// 시/도
    let region1DepthName: String?
    /// 시/군/구
    let region2DepthName: String?

    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
        case region1DepthName = "region_1depth_name"
        case region2DepthName = "region_2depth_name"
    }
}

extension KakaoAddressResponse {

    /// 지정한 행정구역 단위의 Place로 변환, 지역명이 없으면 emptyResult
    func toRegionPlace(coordinate: Coordinate, level: RegionLevel) throws -> Place {
        guard let document = documents.first else {
            throw NetworkError.emptyResult
        }
        let province = document.address?.region1DepthName ?? document.roadAddress?.region1DepthName
        let city = document.address?.region2DepthName ?? document.roadAddress?.region2DepthName

        guard let province, !province.isEmpty else {
            throw NetworkError.emptyResult
        }
        let name: String
        switch level {
        case .province:
            name = province
        case .city:
            guard let city, !city.isEmpty else {
                throw NetworkError.emptyResult
            }
            name = city
        }
        let address = [province, city]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        return Place(
            id: "region_\(level.rawValue)_\(coordinate.latitude)_\(coordinate.longitude)",
            name: name,
            address: address,
            coordinate: coordinate,
            type: .other
        )
    }

    /// Place로 변환, 도로명 우선 없으면 지번, 결과 없으면 emptyResult
    func toPlace(coordinate: Coordinate) throws -> Place {
        guard let document = documents.first else {
            throw NetworkError.emptyResult
        }
        guard let address = document.roadAddress?.addressName ?? document.address?.addressName else {
            throw NetworkError.emptyResult
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
