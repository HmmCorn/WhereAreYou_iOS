//
//  MockPlaceSearchRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-24.
//

import Foundation

final class MockPlaceSearchRepository: PlaceSearchRepository {

    func searchPlaces(
        keyword: String,
        completion: @escaping (Result<[Place], Error>) -> Void
    ) {
        let trimmed = keyword.trimmingCharacters(in: .whitespaces)
        let results: [Place]

        if trimmed.isEmpty {
            results = Self.mockPlaces
        } else {
            results = Self.mockPlaces.filter {
                $0.name.localizedCaseInsensitiveContains(trimmed) ||
                $0.address.localizedCaseInsensitiveContains(trimmed)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            completion(.success(results))
        }
    }

    private static let mockPlaces: [Place] = [
        Place(id: "gangnam", name: "강남역", address: "서울 강남구 강남대로 396",
              coordinate: Coordinate(latitude: 37.4979, longitude: 127.0276), type: .subway),
        Place(id: "hongdae", name: "홍대입구역", address: "서울 마포구 양화로 160",
              coordinate: Coordinate(latitude: 37.5571, longitude: 126.9236), type: .subway),
        Place(id: "jamsil", name: "잠실역", address: "서울 송파구 올림픽로 지하 265",
              coordinate: Coordinate(latitude: 37.5133, longitude: 127.1001), type: .subway),
        Place(id: "seoul_station", name: "서울역", address: "서울 용산구 한강대로 405",
              coordinate: Coordinate(latitude: 37.5547, longitude: 126.9707), type: .station),
        Place(id: "itaewon", name: "이태원역", address: "서울 용산구 이태원로 지하 180",
              coordinate: Coordinate(latitude: 37.5345, longitude: 126.9946), type: .subway),
        Place(id: "yeouido", name: "여의도역", address: "서울 영등포구 의사당대로 지하 166",
              coordinate: Coordinate(latitude: 37.5217, longitude: 126.9244), type: .subway),
        Place(id: "busan_station", name: "부산역", address: "부산 동구 중앙대로 206",
              coordinate: Coordinate(latitude: 35.1152, longitude: 129.0408), type: .station),
        Place(id: "haeundae", name: "해운대역", address: "부산 해운대구 해운대로 지하 772",
              coordinate: Coordinate(latitude: 35.1631, longitude: 129.1635), type: .subway),
    ]

}
