//
//  PlaceSelectionViewModel.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/27/26.
//

import Foundation
import Combine

final class PlaceSelectionViewModel {

    /// 사용자의 현재 GPS 좌표
    @Published private(set) var currentLocation: Coordinate?
    /// 지도 중앙 좌표 기준 근처 장소를 조회 중인지 여부
    @Published private(set) var isFetchingNearbyPlace = false
    /// 지도 중앙 좌표 기준으로 조회된 가장 가까운 장소 1개
    @Published private(set) var nearbyPlace: Place?
    /// currentLocation과 nearbyPlace 사이 거리를 표시용 문자열로 계산해둔 값
    @Published private(set) var distanceText: String?

    /// 지도 중앙 좌표가 바뀔 때마다 이벤트를 흘려보내는 파이프
    private let centerCoordinateSubject = PassthroughSubject<Coordinate, Never>()
    /// Combine 구독을 유지하기 위한 저장소
    private var cancellables = Set<AnyCancellable>()
    /// 마지막으로 실제 조회를 실행했던 좌표
    private var lastFetchedCoordinate: Coordinate?

    /// 이 거리(km) 미만으로 움직였을 때는 재조회하지 않음
    private static let minimumFetchDistanceKm = 0.02

    /// 현재 위치 조회를 위임하는 UseCase
    private let getCurrentLocationUseCase: GetCurrentLocationUseCase
    /// 좌표 기준 근처 장소 조회를 위임하는 UseCase
    private let getNearbyPlaceUseCase: GetNearbyPlaceUseCase

    init(
        getCurrentLocationUseCase: GetCurrentLocationUseCase,
        getNearbyPlaceUseCase: GetNearbyPlaceUseCase
    ) {
        self.getCurrentLocationUseCase = getCurrentLocationUseCase
        self.getNearbyPlaceUseCase = getNearbyPlaceUseCase
        bindCenterCoordinate()
    }

    func fetchCurrentLocation() {
        getCurrentLocationUseCase.execute { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                if case .success(let coordinate) = result {
                    self.currentLocation = coordinate
                    self.setCenterCoordinate(coordinate)
                }
            }
        }
    }

    func setCenterCoordinate(_ coordinate: Coordinate) {
        centerCoordinateSubject.send(coordinate)
    }

    private func bindCenterCoordinate() {
        centerCoordinateSubject
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .filter { [weak self] coordinate in
                guard let self, let lastFetchedCoordinate else { return true }
                return lastFetchedCoordinate.distance(to: coordinate) >= Self.minimumFetchDistanceKm
            }
            .sink { [weak self] coordinate in
                self?.lastFetchedCoordinate = coordinate
                self?.fetchNearbyPlace(at: coordinate)
            }
            .store(in: &cancellables)
    }

    private func fetchNearbyPlace(at coordinate: Coordinate) {
        isFetchingNearbyPlace = true
        getNearbyPlaceUseCase.execute(coordinate: coordinate) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isFetchingNearbyPlace = false
                switch result {
                case .success(let place):
                    self.nearbyPlace = place
                    self.updateDistanceText(for: place)
                case .failure:
                    self.nearbyPlace = nil
                    self.distanceText = nil
                }
            }
        }
    }

    private func updateDistanceText(for place: Place?) {
        guard let place, let currentLocation else {
            distanceText = nil
            return
        }
        let distanceKm = currentLocation.distance(to: place.coordinate)
        distanceText = String(format: "%.1fkm", distanceKm)
    }

}
