//
//  GetRegionPlaceUseCase.swift
//  WhereAreYou
//
//  Created by 김성훈 on 10/9/26.
//

final class GetRegionPlaceUseCase {

    private let reverseGeocodingRepository: ReverseGeocodingRepository

    init(reverseGeocodingRepository: ReverseGeocodingRepository) {
        self.reverseGeocodingRepository = reverseGeocodingRepository
    }

    /// 좌표가 속한 행정구역을 해당 단위의 장소로 조회한다
    func execute(coordinate: Coordinate, level: RegionLevel) async throws -> Place {
        try await reverseGeocodingRepository.reverseGeocodeRegion(coordinate: coordinate, level: level)
    }

}
