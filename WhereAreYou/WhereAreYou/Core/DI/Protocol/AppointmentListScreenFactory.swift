//
//  AppointmentListScreenFactory.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/7/26.
//

protocol AppointmentListScreenFactory: AnyObject {

    func makeChatViewController(
        appointmentID: String,
        completion: @escaping (Result<ChatViewController, Error>) -> Void
    )
    func makeAppointmentRouteViewController(appointmentID: String) -> AppointmentRouteViewController

}

extension ScreenFactory: AppointmentListScreenFactory { }
