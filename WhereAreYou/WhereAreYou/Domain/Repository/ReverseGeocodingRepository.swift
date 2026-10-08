//
//  ReverseGeocodingRepository.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/27/26.
//

protocol ReverseGeocodingRepository {

    func reverseGeocode(coordinate: Coordinate) async throws -> Place

    /// 좌표가 속한 행정구역을 해당 단위의 장소로 반환 (이름은 지역명, 좌표는 입력 좌표)
    func reverseGeocodeRegion(coordinate: Coordinate, level: RegionLevel) async throws -> Place

}
