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

    func toggleNotification(id: String) -> [AppointmentListItem] {
        pastAppointments = pastAppointments.map { toggledIfMatching(id: id, item: $0) }
        return pastAppointments
    }

    func notificationMenuTitle(for item: AppointmentListItem) -> String {
        item.isNotificationEnabled ? "알림 끄기" : "알림 켜기"
    }

    func notificationMenuIcon(for item: AppointmentListItem) -> String {
        item.isNotificationEnabled ? "bell.slash" : "bell"
    }

    func leave(id: String) -> [AppointmentListItem] {
        pastAppointments.removeAll { $0.id == id }
        return pastAppointments
    }

    private func toggledIfMatching(id: String, item: AppointmentListItem) -> AppointmentListItem {
        guard item.id == id else { return item }
        return AppointmentListItem(
            id: item.id,
            title: item.title,
            participantCount: item.participantCount,
            location: item.location,
            date: item.date,
            isNotificationEnabled: !item.isNotificationEnabled
        )
    }

    private func loadDummyData() {
        let allPastAppointments = (1...15).map { index in
            AppointmentListItem(
                id: "past-\(index)",
                title: "지난 약속 \(index)",
                participantCount: index % 10 + 1,
                location: AppointmentLocation(
                    title: "테스트 장소 \(index)",
                    address: "",
                    coordinate: Coordinate(latitude: 0, longitude: 0)
                ),
                date: Calendar.current.date(byAdding: .day, value: -index, to: Date()),
                isNotificationEnabled: true
            )
        }

        pastAppointments = allPastAppointments.sorted {
            ($0.date ?? .distantPast) > ($1.date ?? .distantPast)
        }
    }

}
