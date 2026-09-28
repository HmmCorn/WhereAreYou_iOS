//
//  PlaceSearchRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-24.
//

protocol PlaceSearchRepository {

    @discardableResult
    func searchPlaces(
        keyword: String,
        completion: @escaping (Result<[Place], Error>) -> Void
    ) -> CancellableRequest

}
