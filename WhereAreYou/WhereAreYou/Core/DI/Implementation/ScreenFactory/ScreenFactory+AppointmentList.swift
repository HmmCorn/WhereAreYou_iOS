//
//  ScreenFactory+AppointmentList.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/7/26.
//

extension ScreenFactory {

    func makeAppointmentListViewController() -> AppointmentListViewController {
        AppointmentListViewController()
    }

    func makePastAppointmentListViewController() -> PastAppointmentListViewController {
        PastAppointmentListViewController()
    }

}
