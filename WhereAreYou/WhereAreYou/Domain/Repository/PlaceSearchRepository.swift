//
//  PlaceSearchRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-24.
//

protocol PlaceSearchRepository {

    func searchPlaces(keyword: String) async throws -> [Place]

}
