//
//  SearchPlaceCardViewModel.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-24.
//

import Foundation
import Combine

final class SearchPlaceCardViewModel {

    @Published private(set) var filteredPlaces: [PlaceInfo] = []
    @Published private(set) var selectedFilters: [PlaceType] = []
    @Published private(set) var isSearching = false
    @Published private(set) var hasSearched = false

    private var allPlaces: [Place] = []
    private let searchPlacesUseCase: SearchPlacesUseCase
    private var searchTask: Task<Void, Never>?

    init(searchPlacesUseCase: SearchPlacesUseCase) {
        self.searchPlacesUseCase = searchPlacesUseCase
    }

    deinit {
        searchTask?.cancel()
    }

    func search(keyword: String) {
        searchTask?.cancel()

        let trimmed = keyword.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            isSearching = false
            hasSearched = false
            allPlaces = []
            applyFilter()
            return
        }

        isSearching = true
        searchTask = Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let places = try await self.searchPlacesUseCase.execute(keyword: keyword)
                guard !Task.isCancelled else { return }
                self.isSearching = false
                self.hasSearched = true
                self.allPlaces = places
                self.applyFilter()
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                self.isSearching = false
                self.hasSearched = true
            }
        }
    }

    func toggleFilter(_ placeType: PlaceType) {
        if let index = selectedFilters.firstIndex(of: placeType) {
            selectedFilters.remove(at: index)
        } else {
            selectedFilters.append(placeType)
        }
        applyFilter()
    }

    func resetFilters() {
        selectedFilters = []
        applyFilter()
    }

    func place(for placeInfo: PlaceInfo) -> Place? {
        allPlaces.first { $0.id == placeInfo.id }
    }

    func resetAll() {
        searchTask?.cancel()
        filteredPlaces = []
        selectedFilters = []
        hasSearched = false
        allPlaces = []
    }

    private func applyFilter() {
        let filtered: [Place]
        if selectedFilters.isEmpty {
            filtered = allPlaces
        } else {
            filtered = allPlaces.filter { selectedFilters.contains($0.type) }
        }
        filteredPlaces = filtered.map { PlaceInfo(place: $0) }
    }

}
