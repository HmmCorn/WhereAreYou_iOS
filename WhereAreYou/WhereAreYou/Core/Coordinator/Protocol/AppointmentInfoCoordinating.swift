//
//  AppointmentInfoCoordinating.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

import Foundation

/// AppointmentInfoViewController가 필요로 하는 화면전환만 선언한 프로토콜
protocol AppointmentInfoCoordinating: AnyObject {

    func showDatePicker(initialDate: Date?, onDateSelected: @escaping (Date) -> Void)
    func showSearchPlace(
        selectionButtonTitle: String,
        style: SearchPlaceCardViewController.Style
    ) -> SearchPlaceCardViewController
    func showPlaceMapSelection(initialCoordinate: Coordinate?, onPlaceConfirmed: @escaping (Place) -> Void)

}
