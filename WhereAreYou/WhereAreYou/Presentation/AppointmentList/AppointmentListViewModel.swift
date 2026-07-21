//
//  AppointmentListViewModel.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/21/26.
//

import Foundation

// MARK: - 약속 목록 화면(탭)의 데이터
//       - "오늘 약속"은 date가 오늘 날짜(같은 day)인 약속, "예정된 약속"은 그 외 미래 약속
//       - 오늘 약속이 없으면 todayAppointments가 빈 배열이 되고, 화면은 헤더 없이 예정된 약속만 표시

final class AppointmentListViewModel {

    private(set) var todayAppointments: [AppointmentListItem] = []
    private(set) var upcomingAppointments: [AppointmentListItem] = []

    init() {
        loadDummyData()
    }

    @discardableResult
    func toggleNotification(id: String) -> (today: [AppointmentListItem], upcoming: [AppointmentListItem]) {
        todayAppointments = todayAppointments.map { toggledIfMatching(id: id, item: $0) }
        upcomingAppointments = upcomingAppointments.map { toggledIfMatching(id: id, item: $0) }
        return (todayAppointments, upcomingAppointments)
    }

    @discardableResult
    func leave(id: String) -> (today: [AppointmentListItem], upcoming: [AppointmentListItem]) {
        todayAppointments.removeAll { $0.id == id }
        upcomingAppointments.removeAll { $0.id == id }
        return (todayAppointments, upcomingAppointments)
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
        let allAppointments = [
            AppointmentListItem(
                id: "1",
                title: "고등학교 친구들과 저녁",
                participantCount: 5,
                location: AppointmentLocation(
                    title: "고기굽는방앗간 이수역점",
                    address: "",
                    coordinate: Coordinate(latitude: 0, longitude: 0)
                ),
                date: Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()),
                isNotificationEnabled: true
            ),
            AppointmentListItem(
                id: "today-2",
                title: "오늘 저녁 약속",
                participantCount: 3,
                location: AppointmentLocation(
                    title: "테스트 장소",
                    address: "",
                    coordinate: Coordinate(latitude: 0, longitude: 0)
                ),
                date: Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date()),
                isNotificationEnabled: true
            ),
            AppointmentListItem(
                id: "2",
                title: "고등학교 친구들과 저녁",
                participantCount: 5,
                location: AppointmentLocation(
                    title: "고기굽는방앗간 이수역점",
                    address: "",
                    coordinate: Coordinate(latitude: 0, longitude: 0)
                ),
                date: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
                isNotificationEnabled: true
            ),
            AppointmentListItem(
                id: "3",
                title: "고등학교 친구들과 저녁",
                participantCount: 5,
                location: AppointmentLocation(
                    title: "고기굽는방앗간 이수역점",
                    address: "",
                    coordinate: Coordinate(latitude: 0, longitude: 0)
                ),
                date: Calendar.current.date(byAdding: .day, value: 365, to: Date()),
                isNotificationEnabled: false
            )
        ]

        let (today, upcoming) = allAppointments.reduce(into: ([AppointmentListItem](), [AppointmentListItem]())) { result, item in
            if let date = item.date, Calendar.current.isDateInToday(date) {
                result.0.append(item)
            } else {
                result.1.append(item)
            }
        }

        todayAppointments = today.sorted { ($0.date ?? .distantFuture) < ($1.date ?? .distantFuture) }
        upcomingAppointments = upcoming.sorted { ($0.date ?? .distantFuture) < ($1.date ?? .distantFuture) }
    }

}
