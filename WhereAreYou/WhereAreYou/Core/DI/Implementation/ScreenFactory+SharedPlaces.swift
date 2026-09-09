//
//  ScreenFactory+SharedPlaces.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

extension ScreenFactory {

    func makeSharedPlacesViewController(appointmentID: String, currentUserID: String) -> SharedPlacesViewController {
        let repository = container.resolve(SharedPlaceRepository.self)
        let viewModel = SharedPlacesViewModel(
            appointmentID: appointmentID,
            currentUserID: currentUserID,
            fetchSharedPlacesUseCase: FetchSharedPlacesUseCase(repository: repository),
            votePlaceUseCase: VotePlaceUseCase(repository: repository)
        )
        return SharedPlacesViewController(viewModel: viewModel)
    }

}
