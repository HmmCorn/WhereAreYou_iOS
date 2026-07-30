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
    func execute(
        coordinate: Coordinate,
        completion: @escaping (Result<Place?, Error>) -> Void
    ) {
        nearbyPlaceRepository.fetchNearbyPlace(
            coordinate: coordinate,
            radiusKm: Self.maximumDistanceKm
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let place) where place != nil:
                completion(.success(place))
            case .success:
                self.reverseGeocodingRepository.reverseGeocode(coordinate: coordinate) { geocodeResult in
                    completion(geocodeResult.map { $0 })
                }
            case .failure:
                self.reverseGeocodingRepository.reverseGeocode(coordinate: coordinate) { geocodeResult in
                    completion(geocodeResult.map { $0 })
                }
            }
        }
    }

}
