//
//  ScreenFactory+RouteSearch.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

extension ScreenFactory {

    func makeRouteSearchViewController(departure: Place? = nil, destination: Place? = nil) -> RouteSearchViewController {
        let viewModel = RouteSearchViewModel(
            searchRoutesUseCase: SearchRoutesUseCase(
                repository: container.resolve(RouteSearchRepository.self)
            ),
            getCurrentLocationUseCase: GetCurrentLocationUseCase(
                repository: container.resolve(LocationRepository.self)
            )
        )
        return RouteSearchViewController(viewModel: viewModel, departure: departure, destination: destination)
    }

}
