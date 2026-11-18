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

    @Published private(set) var loadResult: Result<Void, Error>?
    @Published private(set) var leaveResult: Result<Void, Error>?

    private var leavingIDs: Set<String> = []
    private let fetchMyAppointmentsUseCase: FetchMyAppointmentsUseCase
    private let leaveAppointmentUseCase: LeaveAppointmentUseCase

    init(
        fetchMyAppointmentsUseCase: FetchMyAppointmentsUseCase,
        leaveAppointmentUseCase: LeaveAppointmentUseCase
    ) {
        self.fetchMyAppointmentsUseCase = fetchMyAppointmentsUseCase
        self.leaveAppointmentUseCase = leaveAppointmentUseCase
    }

    func loadAppointments() {
        Task { @MainActor in
            do {
                let appointments = try await fetchMyAppointmentsUseCase.execute(
                    from: Calendar.current.startOfDay(for: Date()),
                    to: nil
                )
                // TODO: 약속 알림 연동 시 users.appointmentsNotification 값으로 교체
                let items = appointments.map {
                    AppointmentListItem(
                        appointment: $0,
                        isNotificationEnabled: item(id: $0.id)?.isNotificationEnabled ?? true
                    )
                }
                todayAppointments = items.filter { Calendar.current.isDateInToday($0.date) }
                upcomingAppointments = items.filter { !Calendar.current.isDateInToday($0.date) }
                loadResult = .success(())
            } catch {
                loadResult = .failure(error)
            }
        }
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
        guard leavingIDs.insert(id).inserted else { return }
        Task { @MainActor in
            defer { leavingIDs.remove(id) }
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

}
