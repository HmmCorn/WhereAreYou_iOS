//
//  ReverseGeocodeUseCase.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/27/26.
//

final class ReverseGeocodeUseCase {

    private let repository: ReverseGeocodingRepository

    init(repository: ReverseGeocodingRepository) {
        self.repository = repository
    }

    func execute(
        coordinate: Coordinate,
        completion: @escaping (Result<Place, Error>) -> Void
    ) {
        repository.reverseGeocode(coordinate: coordinate, completion: completion)
    }

}
