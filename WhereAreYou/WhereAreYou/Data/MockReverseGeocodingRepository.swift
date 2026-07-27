//
//  MockReverseGeocodingRepository.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/27/26.
//

import Foundation

final class MockReverseGeocodingRepository: ReverseGeocodingRepository {

    func reverseGeocode(
        coordinate: Coordinate,
        completion: @escaping (Result<Place, Error>) -> Void
    ) {
        let address = Self.mockAddress(near: coordinate)
        let place = Place(
            id: "address_\(coordinate.latitude)_\(coordinate.longitude)",
            name: address,
            address: "",
            coordinate: coordinate,
            type: .other
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            completion(.success(place))
        }
    }

    /// 실제 API의 도로명주소 응답 형태를 흉내낸 더미 주소 생성
    /// 좌표와 가장 가까운 지역 기준점을 찾아 그 지역명 + 임의의 상세 지번을 붙임
    private static func mockAddress(near coordinate: Coordinate) -> String {
        let regionAnchors: [(name: String, coordinate: Coordinate)] = [
            ("서울 강남구 테헤란로", Coordinate(latitude: 37.4979, longitude: 127.0276)),
            ("서울 마포구 양화로", Coordinate(latitude: 37.5571, longitude: 126.9236)),
            ("서울 중구 세종대로", Coordinate(latitude: 37.5665, longitude: 126.9780)),
            ("강원 강릉시 창해로", Coordinate(latitude: 37.7633, longitude: 128.9010)),
            ("강원 춘천시 중앙로", Coordinate(latitude: 37.8770, longitude: 127.7295)),
            ("부산 해운대구 해운대로", Coordinate(latitude: 35.1631, longitude: 129.1635)),
            ("부산 중구 중앙대로", Coordinate(latitude: 35.1152, longitude: 129.0408)),
            ("경남 양산시 물금읍", Coordinate(latitude: 35.3272, longitude: 129.0083)),
        ]

        let nearest = regionAnchors.min {
            $0.coordinate.distance(to: coordinate) < $1.coordinate.distance(to: coordinate)
        }

        let roadName = nearest?.name ?? "알 수 없는 지역"
        let lotNumber = Int.random(in: 1...200)
        return "\(roadName) \(lotNumber)"
    }

}
