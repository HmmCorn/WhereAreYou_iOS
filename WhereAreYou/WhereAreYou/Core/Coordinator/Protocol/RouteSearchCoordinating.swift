//
//  RouteSearchCoordinating.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

import Foundation

/// RouteSearchViewController가 필요로 하는 화면전환만 선언한 프로토콜
protocol RouteSearchCoordinating: AnyObject {

    func showPlaceSearch(buttonTitle: String, onPlaceSelected: @escaping (Place) -> Void)
    func showTimePicker(initialDate: Date, onDateSelected: @escaping (Date) -> Void)

}
