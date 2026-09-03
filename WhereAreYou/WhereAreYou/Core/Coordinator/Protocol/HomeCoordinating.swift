//
//  HomeCoordinating.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

import Foundation

/// HomeViewController가 필요로 하는 화면전환만 선언한 프로토콜
protocol HomeCoordinating: AnyObject {

    func showAppointmentCreation()
    func joinAppointment(code: String, completion: @escaping (Result<Void, Error>) -> Void)
    func showChat(appointmentID: String)
    func showChat(appointmentInfo: AppointmentInfo)

}
