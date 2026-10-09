//
//  GetNearbyPlaceUseCase.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/27/26.
//

final class GetNearbyPlaceUseCase {

    /// 이 거리(km) 이내에 있는 장소만 근처 장소로 인정하는 정책
    private static let maximumDistanceKm = 0.05

    private let nearbyPlaceRepository: NearbyPlaceRepository
    private let reverseGeocodingRepository: ReverseGeocodingRepository

    init(
        nearbyPlaceRepository: NearbyPlaceRepository,
        reverseGeocodingRepository: ReverseGeocodingRepository
    ) {
        self.nearbyPlaceRepository = nearbyPlaceRepository
        self.reverseGeocodingRepository = reverseGeocodingRepository
    }

    /// 좌표 기준 POI를 우선 조회하고, 없으면 역지오코딩 주소로 대체한다
    func execute(coordinate: Coordinate) async throws -> Place? {
        let nearbyPlace: Place?
        do {
            nearbyPlace = try await nearbyPlaceRepository.fetchNearbyPlace(
                coordinate: coordinate,
                radiusKm: Self.maximumDistanceKm
            )
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            nearbyPlace = nil
        }
        if let nearbyPlace {
            return nearbyPlace
        }
        return try await reverseGeocodingRepository.reverseGeocode(coordinate: coordinate)
    }

}
