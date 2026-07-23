//
//  LocationRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-24.
//

protocol LocationRepository {

    func getCurrentLocation(completion: @escaping (Result<Coordinate, Error>) -> Void)

}
