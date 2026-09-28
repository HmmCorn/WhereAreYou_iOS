//
//  RouteSearchViewModel.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-22.
//

import Foundation
import Combine

final class RouteSearchViewModel {

    @Published private(set) var departure: PlaceInfo?
    @Published private(set) var destination: PlaceInfo?
    @Published private(set) var departureTime: Date = Date()
    @Published private(set) var selectedTransportType: TransportType = TransportType.allCases[0]
    @Published private(set) var routes: [RouteItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var selectedRouteIndex: Int = 0

    private var departureDomain: Place?
    private var destinationDomain: Place?
    private var routesDomain: [Route] = []

    private let searchRoutesUseCase: SearchRoutesUseCase
    private let getCurrentLocationUseCase: GetCurrentLocationUseCase
    private let getNearbyPlaceUseCase: GetNearbyPlaceUseCase
    private var fetchCurrentLocationTask: Task<Void, Never>?

    init(
        searchRoutesUseCase: SearchRoutesUseCase,
        getCurrentLocationUseCase: GetCurrentLocationUseCase,
        getNearbyPlaceUseCase: GetNearbyPlaceUseCase
    ) {
        self.searchRoutesUseCase = searchRoutesUseCase
        self.getCurrentLocationUseCase = getCurrentLocationUseCase
        self.getNearbyPlaceUseCase = getNearbyPlaceUseCase
    }

    deinit {
        fetchCurrentLocationTask?.cancel()
    }

    func setDeparture(_ place: Place?) {
        departureDomain = place
        departure = place.map { PlaceInfo(place: $0) }
        searchIfReady()
    }

    func setDestination(_ place: Place?) {
        destinationDomain = place
        destination = place.map { PlaceInfo(place: $0) }
        searchIfReady()
    }

    func setDepartureTime(_ time: Date) {
        departureTime = time
        searchIfReady()
    }

    func setTransportType(_ type: TransportType) {
        selectedTransportType = type
        searchIfReady()
    }

    func selectRoute(at index: Int) {
        guard index >= 0, index < routes.count else { return }
        selectedRouteIndex = index
    }

    func fetchCurrentLocation() {
        fetchCurrentLocationTask?.cancel()
        getCurrentLocationUseCase.execute { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                guard case .success(let coordinate) = result else { return }
                self.fetchCurrentLocationTask = Task { @MainActor [weak self] in
                    guard let self else { return }
                    let nearbyPlace = try? await self.getNearbyPlaceUseCase.execute(coordinate: coordinate)
                    guard !Task.isCancelled else { return }
                    let place = Place(
                        id: "current_location",
                        name: nearbyPlace?.name ?? "현재 위치",
                        address: nearbyPlace?.address ?? "",
                        coordinate: coordinate,
                        type: .other
                    )
                    self.setDeparture(place)
                }
            }
        }
    }

    private func searchIfReady() {
        guard let departureDomain, let destinationDomain else {
            routesDomain = []
            routes = []
            selectedRouteIndex = 0
            return
        }

        isLoading = true

        searchRoutesUseCase.execute(
            departure: departureDomain,
            destination: destinationDomain,
            departureTime: departureTime,
            transportType: selectedTransportType
        ) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                self.selectedRouteIndex = 0

                switch result {
                case .success(let fetchedRoutes):
                    self.routesDomain = fetchedRoutes
                    self.routes = fetchedRoutes.map { RouteItem(route: $0) }
                case .failure:
                    // TODO: 길찾기 API 확인 후 검색 실패 텍스트 설정 필요
                    self.routesDomain = []
                    self.routes = []
                }
            }
        }
    }

}
