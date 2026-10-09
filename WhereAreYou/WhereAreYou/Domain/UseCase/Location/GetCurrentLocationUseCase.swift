//
//  GetCurrentLocationUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-24.
//

final class GetCurrentLocationUseCase {

    private let repository: LocationRepository

    init(repository: LocationRepository) {
        self.repository = repository
    }

    func execute(completion: @escaping (Result<Coordinate, Error>) -> Void) {
        repository.getCurrentLocation(completion: completion)
    }

}
