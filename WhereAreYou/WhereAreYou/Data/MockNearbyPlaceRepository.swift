//
//  MockNearbyPlaceRepository.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/27/26.
//

import Foundation

final class MockNearbyPlaceRepository: NearbyPlaceRepository {

    func fetchNearbyPlace(
        coordinate: Coordinate,
        completion: @escaping (Result<Place?, Error>) -> Void
    ) {
        let nearest = Self.mockPlaces.min {
            $0.coordinate.distance(to: coordinate) < $1.coordinate.distance(to: coordinate)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            completion(.success(nearest))
        }
    }

    private static let mockPlaces: [Place] = [
        // MARK: - 서울

        Place(id: "starbucks_gangnam", name: "스타벅스 강남역점", address: "서울 강남구 테헤란로 124 1층",
              coordinate: Coordinate(latitude: 37.4979, longitude: 127.0276), type: .cafe),
        Place(id: "hongdae", name: "홍대입구역", address: "서울 마포구 양화로 160",
              coordinate: Coordinate(latitude: 37.5571, longitude: 126.9236), type: .subway),
        Place(id: "jamsil", name: "잠실역", address: "서울 송파구 올림픽로 지하 265",
              coordinate: Coordinate(latitude: 37.5133, longitude: 127.1001), type: .subway),
        Place(id: "seoul_station", name: "서울역", address: "서울 용산구 한강대로 405",
              coordinate: Coordinate(latitude: 37.5547, longitude: 126.9707), type: .station),
        Place(id: "itaewon", name: "이태원역", address: "서울 용산구 이태원로 지하 180",
              coordinate: Coordinate(latitude: 37.5345, longitude: 126.9946), type: .subway),
        Place(id: "myeongdong", name: "명동역", address: "서울 중구 퇴계로 지하 130",
              coordinate: Coordinate(latitude: 37.5606, longitude: 126.9862), type: .subway),
        Place(id: "yeouido_park", name: "여의도한강공원", address: "서울 영등포구 여의동로 330",
              coordinate: Coordinate(latitude: 37.5285, longitude: 126.9328), type: .other),
        Place(id: "konkuk_hospital", name: "건국대학교병원", address: "서울 광진구 능동로 120",
              coordinate: Coordinate(latitude: 37.5407, longitude: 127.0700), type: .hospital),
        Place(id: "coex_mall", name: "코엑스몰", address: "서울 강남구 영동대로 513",
              coordinate: Coordinate(latitude: 37.5115, longitude: 127.0590), type: .shop),
        Place(id: "gwangjang_market", name: "광장시장", address: "서울 종로구 창경궁로 88",
              coordinate: Coordinate(latitude: 37.5701, longitude: 126.9997), type: .restaurant),

        // MARK: - 강원도

        Place(id: "gangneung_station", name: "강릉역", address: "강원 강릉시 station로 92",
              coordinate: Coordinate(latitude: 37.7633, longitude: 128.9010), type: .station),
        Place(id: "gyeongpo_beach", name: "경포해변", address: "강원 강릉시 창해로 514",
              coordinate: Coordinate(latitude: 37.8058, longitude: 128.9096), type: .other),
        Place(id: "sokcho_market", name: "속초관광수산시장", address: "강원 속초시 중앙로147번길 12",
              coordinate: Coordinate(latitude: 38.2059, longitude: 128.5918), type: .restaurant),
        Place(id: "chuncheon_myeongdong", name: "춘천 명동거리", address: "강원 춘천시 중앙로77번길 25",
              coordinate: Coordinate(latitude: 37.8770, longitude: 127.7295), type: .shop),
        Place(id: "pyeongchang_hospital", name: "평창병원", address: "강원 평창군 평창읍 군청길 6",
              coordinate: Coordinate(latitude: 37.3705, longitude: 128.3900), type: .hospital),

        // MARK: - 부산

        Place(id: "busan_station", name: "부산역", address: "부산 동구 중앙대로 206",
              coordinate: Coordinate(latitude: 35.1152, longitude: 129.0408), type: .station),
        Place(id: "haeundae", name: "해운대역", address: "부산 해운대구 해운대로 지하 772",
              coordinate: Coordinate(latitude: 35.1631, longitude: 129.1635), type: .subway),
        Place(id: "gwangalli_beach", name: "광안리해수욕장", address: "부산 수영구 광안해변로 219",
              coordinate: Coordinate(latitude: 35.1531, longitude: 129.1187), type: .other),
        Place(id: "seomyeon_cafe", name: "스타벅스 서면점", address: "부산 부산진구 서면로 39",
              coordinate: Coordinate(latitude: 35.1580, longitude: 129.0594), type: .cafe),
        Place(id: "nampo_market", name: "국제시장", address: "부산 중구 신창동4가 상가번영로 5",
              coordinate: Coordinate(latitude: 35.0999, longitude: 129.0289), type: .shop),
        Place(id: "busan_national_hospital", name: "부산대학교병원", address: "부산 서구 구덕로 179",
              coordinate: Coordinate(latitude: 35.1039, longitude: 129.0141), type: .hospital),

        // MARK: - 양산

        Place(id: "yangsan_station", name: "양산역", address: "경남 양산시 양산역로 20",
              coordinate: Coordinate(latitude: 35.3384, longitude: 129.0367), type: .subway),
        Place(id: "yangsan_hospital", name: "양산부산대학교병원", address: "경남 양산시 물금읍 금오로 20",
              coordinate: Coordinate(latitude: 35.3272, longitude: 129.0083), type: .hospital),
        Place(id: "mulgeum_park", name: "황산공원", address: "경남 양산시 물금읍 물금리",
              coordinate: Coordinate(latitude: 35.3221, longitude: 129.0037), type: .other),
        Place(id: "yangsan_market", name: "양산시장", address: "경남 양산시 남부동 505",
              coordinate: Coordinate(latitude: 35.3350, longitude: 129.0378), type: .restaurant),
    ]

}
