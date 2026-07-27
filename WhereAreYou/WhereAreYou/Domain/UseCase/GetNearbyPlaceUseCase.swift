//
//  GetNearbyPlaceUseCase.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/27/26.
//

final class GetNearbyPlaceUseCase {

    /// 이 거리(km) 이내에 있는 장소만 근처 장소로 인정하는 정책
    private static let maximumDistanceKm = 0.05

    private let repository: NearbyPlaceRepository

    init(repository: NearbyPlaceRepository) {
        self.repository = repository
    }

    func execute(
        coordinate: Coordinate,
        completion: @escaping (Result<Place?, Error>) -> Void
    ) {
        repository.fetchNearbyPlace(
            coordinate: coordinate,
            radiusKm: Self.maximumDistanceKm,
            completion: completion
        )
    }

}
