//
//  ReverseGeocodingRepository.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/27/26.
//

protocol ReverseGeocodingRepository {

    func reverseGeocode(
        coordinate: Coordinate,
        completion: @escaping (Result<Place, Error>) -> Void
    )

}
