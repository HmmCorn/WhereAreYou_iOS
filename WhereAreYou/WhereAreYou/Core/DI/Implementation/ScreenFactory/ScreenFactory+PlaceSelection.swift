//
//  ScreenFactory+PlaceSelection.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

extension ScreenFactory {

    func makePlaceSelectionViewController(initialCoordinate: Coordinate?) -> PlaceSelectionViewController {
        let viewModel = PlaceSelectionViewModel(
            getCurrentLocationUseCase: GetCurrentLocationUseCase(
                repository: container.resolve(LocationRepository.self)
            ),
            getNearbyPlaceUseCase: GetNearbyPlaceUseCase(
                nearbyPlaceRepository: container.resolve(NearbyPlaceRepository.self),
                reverseGeocodingRepository: container.resolve(ReverseGeocodingRepository.self)
            ),
            initialCoordinate: initialCoordinate
        )
        return PlaceSelectionViewController(viewModel: viewModel)
    }

}
