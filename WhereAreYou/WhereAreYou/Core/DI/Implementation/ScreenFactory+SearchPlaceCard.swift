//
//  ScreenFactory+SearchPlaceCard.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

extension ScreenFactory {

    func makeSearchPlaceCardViewController(
        selectionButtonTitle: String,
        style: SearchPlaceCardViewController.Style
    ) -> SearchPlaceCardViewController {
        let viewModel = SearchPlaceCardViewModel(
            searchPlacesUseCase: SearchPlacesUseCase(repository: container.resolve(PlaceSearchRepository.self))
        )
        return SearchPlaceCardViewController(
            viewModel: viewModel,
            selectionButtonTitle: selectionButtonTitle,
            style: style
        )
    }

}
