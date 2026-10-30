//
//  SearchRoutesUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-22.
//

import Foundation

final class SearchRoutesUseCase {

    private let repository: RouteSearchRepository

    init(repository: RouteSearchRepository) {
        self.repository = repository
    }

    func execute(
        departure: Place,
        destination: Place,
        departureTime: Date,
        transportType: TransportType
    ) async throws -> [Route] {
        try await repository.searchRoutes(
            departure: departure,
            destination: destination,
            departureTime: departureTime,
            transportType: transportType
        )
    }

}
