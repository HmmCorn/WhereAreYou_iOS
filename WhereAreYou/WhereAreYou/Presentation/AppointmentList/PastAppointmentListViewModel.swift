//
//  PastAppointmentListViewModel.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/21/26.
//

import Foundation

// MARK: - 지난 약속 화면의 데이터
//       - 약속 시각이 지났고, 지난 지 30일 이내인 약속만 보관

final class PastAppointmentListViewModel {

    private(set) var pastAppointments: [AppointmentListItem] = []

    init() {
        loadDummyData()
    }

    @discardableResult
    func delete(id: String) -> [AppointmentListItem] {
        pastAppointments.removeAll { $0.id == id }
        return pastAppointments
    }

    private func loadDummyData() {
        let allPastAppointments = [
            AppointmentListItem(
                id: "past-1",
                title: "고등학교 친구들과 저녁",
                participantCount: 5,
                location: AppointmentLocation(
                    title: "고기굽는방앗간 이수역점",
                    address: "",
                    coordinate: Coordinate(latitude: 0, longitude: 0)
                ),
                date: Calendar.current.date(byAdding: .day, value: -5, to: Date()),
                isNotificationEnabled: true
            ),
            AppointmentListItem(
                id: "past-2",
                title: "동아리 MT",
                participantCount: 12,
                location: AppointmentLocation(
                    title: "강촌 펜션",
                    address: "",
                    coordinate: Coordinate(latitude: 0, longitude: 0)
                ),
                date: Calendar.current.date(byAdding: .day, value: -20, to: Date()),
                isNotificationEnabled: true
            )
        ]

        pastAppointments = allPastAppointments.sorted {
            ($0.date ?? .distantPast) > ($1.date ?? .distantPast)
        }
    }

}
