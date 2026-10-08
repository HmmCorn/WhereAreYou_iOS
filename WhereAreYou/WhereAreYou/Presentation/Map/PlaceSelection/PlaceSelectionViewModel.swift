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
    @Published private(set) var nearbyPlace: PlaceInfo?
    /// currentLocation과 nearbyPlace 사이 거리를 표시용 문자열로 계산해둔 값
    @Published private(set) var distanceText: String?

    private(set) var nearbyPlaceDomain: Place?
    /// 지도의 마지막 줌 레벨 — 카메라 이동이 멈출 때 갱신
    private(set) var zoomLevel: Double?
    /// 지도 중앙 좌표가 바뀔 때마다 이벤트를 흘려보내는 파이프
    private let centerCoordinateSubject = PassthroughSubject<Coordinate, Never>()
    /// Combine 구독을 유지하기 위한 저장소
    private var cancellables = Set<AnyCancellable>()
    /// 마지막으로 실제 조회를 실행했던 좌표
    private var lastFetchedCoordinate: Coordinate?
    /// 마지막으로 실제 조회를 실행했던 조회 방식
    private var lastFetchedMode: FetchMode?
    /// 진행 중인 근처 장소 조회 Task — 새 좌표가 들어오면 이전 Task를 취소해 응답 경쟁을 막음
    private var nearbyPlaceTask: Task<Void, Never>?

    /// 줌 레벨에 따른 조회 방식
    private enum FetchMode: Equatable {
        case nearbyPlace
        case region(RegionLevel)

        /// 이 거리(km) 미만으로 움직였을 때는 재조회하지 않음
        var minimumFetchDistanceKm: Double {
            switch self {
            case .nearbyPlace: return 0.03
            case .region(.city): return 0.5
            case .region(.province): return 3
            }
        }
    }

    /// 이 줌 레벨 이상이면 주변 장소 조회
    private static let nearbyPlaceMinimumZoomLevel = 14.0
    /// 이 줌 레벨 이상(주변 장소 미만)이면 시/군/구, 미만이면 시/도 조회
    private static let cityMinimumZoomLevel = 9.0

    /// 현재 줌 레벨에 해당하는 조회 방식, 줌 레벨을 모르면 주변 장소
    private var currentFetchMode: FetchMode {
        guard let zoomLevel else { return .nearbyPlace }
        if zoomLevel >= Self.nearbyPlaceMinimumZoomLevel { return .nearbyPlace }
        if zoomLevel >= Self.cityMinimumZoomLevel { return .region(.city) }
        return .region(.province)
    }

    /// 현재 위치 조회를 위임하는 UseCase
    private let getCurrentLocationUseCase: GetCurrentLocationUseCase
    /// 좌표 기준 근처 장소 조회를 위임하는 UseCase
    private let getNearbyPlaceUseCase: GetNearbyPlaceUseCase
    /// 좌표가 속한 지역명 조회를 위임하는 UseCase
    private let getRegionPlaceUseCase: GetRegionPlaceUseCase
    /// 초기 지도 중심 좌표 (nil이면 현재 위치 사용)
    let initialCoordinate: Coordinate?

    init(
        getCurrentLocationUseCase: GetCurrentLocationUseCase,
        getNearbyPlaceUseCase: GetNearbyPlaceUseCase,
        getRegionPlaceUseCase: GetRegionPlaceUseCase,
        initialCoordinate: Coordinate? = nil
    ) {
        self.getCurrentLocationUseCase = getCurrentLocationUseCase
        self.getNearbyPlaceUseCase = getNearbyPlaceUseCase
        self.getRegionPlaceUseCase = getRegionPlaceUseCase
        self.initialCoordinate = initialCoordinate
        bindCenterCoordinate()
    }

    deinit {
        nearbyPlaceTask?.cancel()
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

    /// zoomLevel이 nil이면 직전에 전달된 줌 레벨을 유지 (현재 위치·초기 좌표처럼 줌 정보가 없는 호출)
    func setCenterCoordinate(_ coordinate: Coordinate, zoomLevel: Double? = nil) {
        if let zoomLevel {
            self.zoomLevel = zoomLevel
        }
        centerCoordinateSubject.send(coordinate)
    }

    private func bindCenterCoordinate() {
        centerCoordinateSubject
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .filter { [weak self] coordinate in
                guard let self, let lastFetchedCoordinate, let lastFetchedMode else { return true }
                let mode = self.currentFetchMode
                // 줌 레벨 변화로 조회 방식이 바뀌면 같은 위치여도 재조회
                if mode != lastFetchedMode { return true }
                return lastFetchedCoordinate.distance(to: coordinate) >= mode.minimumFetchDistanceKm
            }
            .sink { [weak self] coordinate in
                guard let self else { return }
                let mode = self.currentFetchMode
                self.lastFetchedCoordinate = coordinate
                self.lastFetchedMode = mode
                self.fetchPlace(at: coordinate, mode: mode)
            }
            .store(in: &cancellables)
    }

    private func fetchPlace(at coordinate: Coordinate, mode: FetchMode) {
        nearbyPlaceTask?.cancel()
        isFetchingNearbyPlace = true
        nearbyPlaceTask = Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let fetchedPlace: Place?
                switch mode {
                case .nearbyPlace:
                    fetchedPlace = try await self.getNearbyPlaceUseCase.execute(coordinate: coordinate)
                case .region(let level):
                    fetchedPlace = try await self.getRegionPlaceUseCase.execute(coordinate: coordinate, level: level)
                }
                guard !Task.isCancelled else { return }
                self.isFetchingNearbyPlace = false
                self.nearbyPlaceDomain = fetchedPlace
                self.nearbyPlace = fetchedPlace.map { PlaceInfo(place: $0) }
                self.updateDistanceText(for: fetchedPlace)
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                self.isFetchingNearbyPlace = false
                self.nearbyPlaceDomain = nil
                self.nearbyPlace = nil
                self.distanceText = nil
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
