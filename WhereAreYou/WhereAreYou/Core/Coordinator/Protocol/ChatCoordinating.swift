//
//  ChatCoordinating.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

import Foundation

/// ChatViewController가 필요로 하는 화면전환만 선언한 프로토콜
protocol ChatCoordinating: AnyObject {

    func showAppointmentRoute(appointmentID: String)
    func showAppointmentInfo(appointmentID: String) -> AppointmentInfoViewController
    func showShareMyLocationConfirm(address: String, onConfirm: @escaping () -> Void)
    func showSearchPlace(
        selectionButtonTitle: String,
        style: SearchPlaceCardViewController.Style
    ) -> SearchPlaceCardViewController
    func showSharedPlaces(appointmentID: String, currentUserID: String)

}
