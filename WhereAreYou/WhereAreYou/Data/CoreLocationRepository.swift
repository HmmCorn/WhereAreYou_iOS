//
//  CoreLocationRepository.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/28/26.
//

import Combine
import CoreLocation

final class CoreLocationRepository: NSObject, LocationRepository {

    private let locationManager = CLLocationManager()
    private var completion: ((Result<Coordinate, Error>) -> Void)?

    private let authorizationStatusSubject: CurrentValueSubject<LocationPermissionStatus, Never>

    enum LocationError: Error {
        case permissionDenied
        case unableToFetch
    }

    override init() {
        authorizationStatusSubject = CurrentValueSubject(
            LocationPermissionStatus(locationManager.authorizationStatus)
        )
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

// MARK: - LocationPermissionRepository

extension CoreLocationRepository: LocationPermissionRepository {

    var authorizationStatus: LocationPermissionStatus {
        LocationPermissionStatus(locationManager.authorizationStatus)
    }

    var authorizationStatusPublisher: AnyPublisher<LocationPermissionStatus, Never> {
        authorizationStatusSubject.eraseToAnyPublisher()
    }

    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

}

extension CoreLocationRepository: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatusSubject.send(LocationPermissionStatus(manager.authorizationStatus))

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

// MARK: - CLAuthorizationStatus 변환

private extension LocationPermissionStatus {

    init(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined: self = .notDetermined
        case .denied: self = .denied
        case .restricted: self = .restricted
        case .authorizedAlways: self = .authorizedAlways
        case .authorizedWhenInUse: self = .authorizedWhenInUse
        @unknown default: self = .notDetermined
        }
    }

}
