//
//  GetNearbyPlaceUseCase.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/27/26.
//

final class GetNearbyPlaceUseCase {

    private let repository: NearbyPlaceRepository

    init(repository: NearbyPlaceRepository) {
        self.repository = repository
    }

    func execute(
        coordinate: Coordinate,
        completion: @escaping (Result<Place?, Error>) -> Void
    ) {
        repository.fetchNearbyPlace(coordinate: coordinate, completion: completion)
    }

}
