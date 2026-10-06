//
//  GetCurrentLocationPlaceUseCase.swift
//  WhereAreYou
//
//  Created by 김성훈 on 10/2/26.
//

final class GetCurrentLocationPlaceUseCase {

    private let locationRepository: LocationRepository
    private let getNearbyPlaceUseCase: GetNearbyPlaceUseCase

    init(
        locationRepository: LocationRepository,
        getNearbyPlaceUseCase: GetNearbyPlaceUseCase
    ) {
        self.locationRepository = locationRepository
        self.getNearbyPlaceUseCase = getNearbyPlaceUseCase
    }

    /// 현재 좌표 조회 후 근처 장소 조회 — 좌표 조회 실패는 throw, 장소 조회 실패는 nil로 대체
    func execute() async throws -> (coordinate: Coordinate, place: Place?) {
        let coordinate = try await currentCoordinate()

        let place: Place?
        do {
            place = try await getNearbyPlaceUseCase.execute(coordinate: coordinate)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            place = nil
        }
        return (coordinate, place)
    }

    // MARK: - Private

    /// completion 기반 현재 위치 조회를 async로 변환
    private func currentCoordinate() async throws -> Coordinate {
        try await withCheckedThrowingContinuation { continuation in
            locationRepository.getCurrentLocation { continuation.resume(with: $0) }
        }
    }

}
