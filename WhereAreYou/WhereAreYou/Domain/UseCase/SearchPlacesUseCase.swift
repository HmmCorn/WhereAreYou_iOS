//
//  SearchPlacesUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-24.
//

final class SearchPlacesUseCase {

    private let repository: PlaceSearchRepository
    private let locationRepository: LocationRepository
    private let locationPermissionRepository: LocationPermissionRepository

    init(
        repository: PlaceSearchRepository,
        locationRepository: LocationRepository,
        locationPermissionRepository: LocationPermissionRepository
    ) {
        self.repository = repository
        self.locationRepository = locationRepository
        self.locationPermissionRepository = locationPermissionRepository
    }

    /// 현재 위치를 얻을 수 있으면 가까운 장소를 우대해 검색, 얻을 수 없으면 키워드만으로 검색
    func execute(keyword: String) async throws -> [Place] {
        let coordinate = await currentCoordinate()
        try Task.checkCancellation()
        return try await repository.searchPlaces(keyword: keyword, near: coordinate)
    }

    // MARK: - Private

    /// 권한이 이미 허용된 경우에만 조회(검색 중 권한 팝업 방지), 실패는 nil로 대체
    private func currentCoordinate() async -> Coordinate? {
        switch locationPermissionRepository.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            break
        case .notDetermined, .denied, .restricted:
            return nil
        }
        return try? await withCheckedThrowingContinuation { continuation in
            locationRepository.getCurrentLocation { continuation.resume(with: $0) }
        }
    }

}
