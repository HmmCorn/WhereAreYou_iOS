//
//  CoreLocationRepository.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/28/26.
//

import CoreLocation

final class CoreLocationRepository: NSObject, LocationRepository {

    private let locationManager = CLLocationManager()
    private var completion: ((Result<Coordinate, Error>) -> Void)?

    enum LocationError: Error {
        case permissionDenied
        case unableToFetch
    }

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func getCurrentLocation(completion: @escaping (Result<Coordinate, Error>) -> Void) {
        self.completion = completion

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            completion(.failure(LocationError.permissionDenied))
            self.completion = nil
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        @unknown default:
            completion(.failure(LocationError.unableToFetch))
            self.completion = nil
        }
    }

}

extension CoreLocationRepository: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            completion?(.failure(LocationError.permissionDenied))
            completion = nil
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            completion?(.failure(LocationError.unableToFetch))
            completion = nil
            return
        }
        completion?(.success(
            Coordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        ))
        completion = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completion?(.failure(error))
        completion = nil
    }

}
