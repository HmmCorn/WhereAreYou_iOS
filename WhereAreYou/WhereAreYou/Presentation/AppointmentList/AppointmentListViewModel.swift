//
//  AppointmentListViewModel.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/21/26.
//

import Foundation
import Combine

// MARK: - 약속 목록 화면(탭)의 데이터
//       - "오늘 약속"은 date가 오늘 날짜(같은 day)인 약속, "예정된 약속"은 그 외 미래 약속
//       - 오늘 약속이 없으면 todayAppointments가 빈 배열이 되고, 화면은 헤더 없이 예정된 약속만 표시

final class AppointmentListViewModel {

    private(set) var todayAppointments: [AppointmentListItem] = []
    private(set) var upcomingAppointments: [AppointmentListItem] = []

    @Published private(set) var leaveResult: Result<Void, Error>?

    private let leaveAppointmentUseCase: LeaveAppointmentUseCase

    init(leaveAppointmentUseCase: LeaveAppointmentUseCase) {
        self.leaveAppointmentUseCase = leaveAppointmentUseCase
        loadDummyData()
    }

    func toggleNotification(id: String) {
        if let index = todayAppointments.firstIndex(where: { $0.id == id }) {
            todayAppointments[index] = toggledNotification(of: todayAppointments[index])
            return
        }
        if let index = upcomingAppointments.firstIndex(where: { $0.id == id }) {
            upcomingAppointments[index] = toggledNotification(of: upcomingAppointments[index])
        }
    }

    func item(id: String) -> AppointmentListItem? {
        todayAppointments.first { $0.id == id } ?? upcomingAppointments.first { $0.id == id }
    }

    func notificationMenuTitle(for item: AppointmentListItem) -> String {
        item.isNotificationEnabled ? "알림 끄기" : "알림 켜기"
    }

    func notificationMenuIcon(for item: AppointmentListItem) -> String {
        item.isNotificationEnabled ? "bell.slash" : "bell"
    }

    func leave(id: String) {
        Task { @MainActor in
            do {
                try await leaveAppointmentUseCase.execute(appointmentID: id)
                todayAppointments.removeAll { $0.id == id }
                upcomingAppointments.removeAll { $0.id == id }
                leaveResult = .success(())
            } catch {
                leaveResult = .failure(error)
            }
        }
    }

    private func toggledNotification(of item: AppointmentListItem) -> AppointmentListItem {
        AppointmentListItem(
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
                date: Calendar.current.startOfDay(for: Date()).addingTimeInterval(12 * 60 * 60),
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
                date: Calendar.current.startOfDay(for: Date()),
                isNotificationEnabled: true
            ),
            AppointmentListItem(
                id: "today-3",
                title: "곧 시작하는 약속",
                participantCount: 4,
                location: AppointmentLocation(
                    title: "테스트 장소",
                    address: "",
                    coordinate: Coordinate(latitude: 0, longitude: 0)
                ),
                date: Date().addingTimeInterval(30 * 60),
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
                date: Date().addingTimeInterval(1 * 24 * 60 * 60),
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
                date: Date().addingTimeInterval(365 * 24 * 60 * 60),
                isNotificationEnabled: false
            )
        ]

        let (today, upcoming) = allAppointments.reduce(into: ([AppointmentListItem](), [AppointmentListItem]())) { result, item in
            if Calendar.current.isDateInToday(item.date) {
                result.0.append(item)
            } else {
                result.1.append(item)
            }
        }

        todayAppointments = today.sorted { $0.date < $1.date }
        upcomingAppointments = upcoming.sorted { $0.date < $1.date }
    }

}
