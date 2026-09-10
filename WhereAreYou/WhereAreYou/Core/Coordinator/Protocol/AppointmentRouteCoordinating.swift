//
//  AppointmentRouteCoordinating.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

import UIKit

/// AppointmentRouteViewController가 필요로 하는 화면전환만 선언한 프로토콜
protocol AppointmentRouteCoordinating: AnyObject {

    /// "경로 변경" 시 경로 검색 화면을 모달로 띄운다.
    /// RouteSearchCoordinator의 생성과 소유는 이 프로토콜을 구현하는 상위 Coordinator가 담당한다.
    func showRouteSearch(from presentingViewController: UIViewController, destination: Place?)

}
