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

    /// 카카오가 약칭으로 내려주는 시/도명을 정식 명칭으로 변환
    /// 이미 정식 명칭이거나 매핑이 없으면 그대로 사용
    private static let provinceFullNames: [String: String] = [
        "서울": "서울특별시",
        "부산": "부산광역시",
        "대구": "대구광역시",
        "인천": "인천광역시",
        "광주": "광주광역시",
        "대전": "대전광역시",
        "울산": "울산광역시",
        "세종": "세종특별자치시",
        "경기": "경기도",
        "강원": "강원특별자치도",
        "충북": "충청북도",
        "충남": "충청남도",
        "전북": "전북특별자치도",
        "전남": "전라남도",
        "경북": "경상북도",
        "경남": "경상남도",
        "제주": "제주특별자치도",
    ]

    /// 지정한 행정구역 단위의 Place로 변환, 지역명이 없으면 emptyResult
    func toRegionPlace(coordinate: Coordinate, level: RegionLevel) throws -> Place {
        guard let document = documents.first else {
            throw NetworkError.emptyResult
        }
        let rawProvince = document.address?.region1DepthName ?? document.roadAddress?.region1DepthName
        let city = document.address?.region2DepthName ?? document.roadAddress?.region2DepthName

        guard let rawProvince, !rawProvince.isEmpty else {
            throw NetworkError.emptyResult
        }
        let province = Self.provinceFullNames[rawProvince] ?? rawProvince
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
