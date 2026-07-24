//
//  RouteSearchRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-22.
//

import Foundation

protocol RouteSearchRepository {

    func searchRoutes(
        departure: Place,
        destination: Place,
        departureTime: Date,
        transportType: TransportType,
        completion: @escaping (Result<[Route], Error>) -> Void
    )

}
