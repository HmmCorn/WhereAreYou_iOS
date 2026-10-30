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
    /// 경로 검색 실패 문구, 성공 시 nil
    @Published private(set) var searchErrorMessage: String?

    private var departureDomain: Place?
    private var destinationDomain: Place?
    private var routesDomain: [Route] = []

    private let searchRoutesUseCase: SearchRoutesUseCase
    private let getCurrentLocationPlaceUseCase: GetCurrentLocationPlaceUseCase
    private var fetchCurrentLocationTask: Task<Void, Never>?
    private var searchRoutesTask: Task<Void, Never>?

    init(
        searchRoutesUseCase: SearchRoutesUseCase,
        getCurrentLocationPlaceUseCase: GetCurrentLocationPlaceUseCase
    ) {
        self.searchRoutesUseCase = searchRoutesUseCase
        self.getCurrentLocationPlaceUseCase = getCurrentLocationPlaceUseCase
    }

    deinit {
        fetchCurrentLocationTask?.cancel()
        searchRoutesTask?.cancel()
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
        fetchCurrentLocationTask = Task { @MainActor [weak self] in
            guard let self, let result = try? await self.getCurrentLocationPlaceUseCase.execute() else { return }
            guard !Task.isCancelled else { return }
            let place = Place(
                id: "current_location",
                name: result.place?.name ?? "현재 위치",
                address: result.place?.address ?? "",
                coordinate: result.coordinate,
                type: .other
            )
            self.setDeparture(place)
        }
    }

    /// 이전 검색 취소 후 재검색
    private func searchIfReady() {
        searchRoutesTask?.cancel()

        searchErrorMessage = nil

        guard let departureDomain, let destinationDomain else {
            isLoading = false
            routesDomain = []
            routes = []
            selectedRouteIndex = 0
            return
        }

        isLoading = true

        let departureTime = departureTime
        let transportType = selectedTransportType
        searchRoutesTask = Task { [weak self] in
            guard let self else { return }
            let fetchedRoutes: [Route]
            var errorMessage: String?
            do {
                fetchedRoutes = try await self.searchRoutesUseCase.execute(
                    departure: departureDomain,
                    destination: destinationDomain,
                    departureTime: departureTime,
                    transportType: transportType
                )
            } catch {
                fetchedRoutes = []
                errorMessage = (error as? LocalizedError)?.errorDescription
                    ?? AppError.unknown(error).errorDescription
            }
            // 취소로 인한 에러도 여기서 걸러짐
            guard !Task.isCancelled else { return }

            self.searchErrorMessage = errorMessage
            self.isLoading = false
            self.selectedRouteIndex = 0
            self.routesDomain = fetchedRoutes
            self.routes = fetchedRoutes.map { RouteItem(route: $0) }
        }
    }

}
