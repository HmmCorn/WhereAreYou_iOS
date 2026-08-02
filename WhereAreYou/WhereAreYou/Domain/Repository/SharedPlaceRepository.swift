//
//  SharedPlaceRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-03.
//

protocol SharedPlaceRepository {
    func fetchSharedPlaces(appointmentID: String, completion: @escaping (Result<[SharedPlace], Error>) -> Void)
    func sharePlace(appointmentID: String, place: Place, completion: @escaping (Result<SharedPlace, Error>) -> Void)
    func voteForPlace(appointmentID: String, placeID: String, completion: @escaping (Result<SharedPlace, Error>) -> Void)
}
