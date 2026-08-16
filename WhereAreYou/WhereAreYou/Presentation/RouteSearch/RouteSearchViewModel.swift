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

    init(
        searchRoutesUseCase: SearchRoutesUseCase,
        getCurrentLocationUseCase: GetCurrentLocationUseCase
    ) {
        self.searchRoutesUseCase = searchRoutesUseCase
        self.getCurrentLocationUseCase = getCurrentLocationUseCase
    }

    func setDeparture(_ place: Place?) {
        departureDomain = place
        departure = place.map(PlaceInfo.init)
        searchIfReady()
    }

    func setDestination(_ place: Place?) {
        destinationDomain = place
        destination = place.map(PlaceInfo.init)
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
        getCurrentLocationUseCase.execute { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                if case .success(let coordinate) = result {
                    let place = Place(
                        id: "current_location",
                        name: "현재 위치",
                        address: "",
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
                    self.routes = fetchedRoutes.map(RouteItem.init)
                case .failure:
                    // TODO: 길찾기 API 확인 후 검색 실패 텍스트 설정 필요
                    self.routesDomain = []
                    self.routes = []
                }
            }
        }
    }

}
