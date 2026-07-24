//
//  SearchPlacesUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-24.
//

final class SearchPlacesUseCase {

    private let repository: PlaceSearchRepository

    init(repository: PlaceSearchRepository) {
        self.repository = repository
    }

    func execute(
        keyword: String,
        completion: @escaping (Result<[Place], Error>) -> Void
    ) {
        repository.searchPlaces(keyword: keyword, completion: completion)
    }

}
