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

    init(searchPlacesUseCase: SearchPlacesUseCase) {
        self.searchPlacesUseCase = searchPlacesUseCase
    }

    func search(keyword: String) {
        isSearching = true
        searchPlacesUseCase.execute(keyword: keyword) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isSearching = false
                self.hasSearched = true
                if case .success(let places) = result {
                    self.allPlaces = places
                    self.applyFilter()
                }
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
        filteredPlaces = filtered.map(PlaceInfo.init)
    }

}
