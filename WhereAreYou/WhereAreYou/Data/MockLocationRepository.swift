//
//  MockLocationRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-24.
//

import Foundation

final class MockLocationRepository: LocationRepository {

    func getCurrentLocation(completion: @escaping (Result<Coordinate, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(Coordinate(latitude: 37.5665, longitude: 126.9780)))
        }
    }

}
