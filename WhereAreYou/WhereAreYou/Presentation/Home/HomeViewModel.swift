//
//  HomeViewModel.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/16/26.
//

import Foundation

final class HomeViewModel {

    private(set) var upcomingAppointments: [UpcomingAppointment] = []

    init() {
        loadDummyData()
    }

    private func loadDummyData() {
        upcomingAppointments = [
            UpcomingAppointment(
                id: "1",
                title: "고등학교 친구들과 저녁",
                participantCount: 5,
                location: AppointmentLocation(
                    title: "고기굽는방앗간 이수역점",
                    address: "",
                    coordinate: Coordinate(latitude: 0, longitude: 0)
                ),
                date: Calendar.current.date(byAdding: .hour, value: 10, to: Date())
            ),
            UpcomingAppointment(
                id: "2",
                title: "동아리 MT",
                participantCount: 12,
                location: AppointmentLocation(
                    title: "강촌 펜션",
                    address: "",
                    coordinate: Coordinate(latitude: 0, longitude: 0)
                ),
                date: Calendar.current.date(byAdding: .hour, value: 30, to: Date())
            ),
            UpcomingAppointment(
                id: "3",
                title: "생일 파티",
                participantCount: 8,
                location: AppointmentLocation(
                    title: "홍대 파티룸",
                    address: "",
                    coordinate: Coordinate(latitude: 0, longitude: 0)
                ),
                date: Calendar.current.date(byAdding: .hour, value: 3, to: Date())
            )
        ]
        .sorted { ($0.date ?? .distantFuture) < ($1.date ?? .distantFuture) }
    }

}
