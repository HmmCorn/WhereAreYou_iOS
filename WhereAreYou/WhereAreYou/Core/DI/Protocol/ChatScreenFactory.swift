//
//  ChatScreenFactory.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/7/26.
//

protocol ChatScreenFactory: SearchPlaceScreenFactory {

    func makeAppointmentInfoViewController(appointmentID: String) -> AppointmentInfoViewController
    func makeAppointmentRouteViewController(appointmentID: String) -> AppointmentRouteViewController
    func makePlaceSelectionViewController(initialCoordinate: Coordinate?) -> PlaceSelectionViewController
    func makeSharedPlacesViewController(appointmentID: String, currentUserID: String) -> SharedPlacesViewController
    func makeLocationPreviewViewController(title: String, subtitle: String?, coordinate: Coordinate) -> LocationPreviewViewController

}

extension ScreenFactory: ChatScreenFactory { }
