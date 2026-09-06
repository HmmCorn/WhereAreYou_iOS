//
//  AppointmentCreationCoordinating.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

import UIKit

/// AppointmentCreationViewController가 필요로 하는 화면전환만 선언한 프로토콜
protocol AppointmentCreationCoordinating: AnyObject {

    func replaceAppointmentCreation(
        _ appointmentCreationViewController: UIViewController,
        withChatFor appointmentInfo: AppointmentInfo
    )
    func showPlaceSearch(
        selectionButtonTitle: String,
        style: SearchPlaceCardViewController.Style
    ) -> SearchPlaceCardViewController
    func showPlaceMapSelection(initialCoordinate: Coordinate?, onPlaceConfirmed: @escaping (Place) -> Void)
    func showDatePicker(title: String, initialDate: Date?, onDateSelected: @escaping (Date) -> Void)

}
