//
//  HomeScreenFactory.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/7/26.
//

protocol HomeScreenFactory: SearchPlaceScreenFactory {

    func makeHomeViewController() -> HomeViewController
    func makeAppointmentCreationViewController() -> AppointmentCreationViewController
    func makeChatViewController(appointmentInfo: AppointmentInfo) -> ChatViewController
    func makeChatViewController(
        appointmentID: String,
        completion: @escaping (Result<ChatViewController, Error>) -> Void
    )
    func makePlaceSelectionViewController(initialCoordinate: Coordinate?) -> PlaceSelectionViewController

}

extension ScreenFactory: HomeScreenFactory { }
