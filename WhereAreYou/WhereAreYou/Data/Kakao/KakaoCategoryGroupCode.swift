//
//  KakaoCategoryGroupCode.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/29/26.
//

import Foundation

/// 카카오 로컬 API 카테고리 그룹 코드 전체
enum KakaoCategoryGroupCode: String {
    case largeMart = "MT1"        // 대형마트
    case convenienceStore = "CS2" // 편의점
    case kindergarten = "PS3"     // 어린이집, 유치원
    case school = "SC4"           // 학교
    case academy = "AC5"          // 학원
    case parkingLot = "PK6"       // 주차장
    case gasStation = "OL7"       // 주유소, 충전소
    case subwayStation = "SW8"    // 지하철역
    case bank = "BK9"             // 은행
    case culturalFacility = "CT1" // 문화시설
    case brokerage = "AG2"        // 중개업소
    case publicInstitution = "PO3" // 공공기관
    case attraction = "AT4"       // 관광명소
    case accommodation = "AD5"    // 숙박
    case restaurant = "FD6"       // 음식점
    case cafe = "CE7"             // 카페
    case hospital = "HP8"         // 병원
    case pharmacy = "PM9"         // 약국
}
