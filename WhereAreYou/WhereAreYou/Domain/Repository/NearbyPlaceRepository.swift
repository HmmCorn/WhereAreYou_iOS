//
//  NearbyPlaceRepository.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/27/26.
//

protocol NearbyPlaceRepository {

    @discardableResult
    func fetchNearbyPlace(
        coordinate: Coordinate,
        radiusKm: Double,
        completion: @escaping (Result<Place?, Error>) -> Void
    ) -> CancellableRequest

}
