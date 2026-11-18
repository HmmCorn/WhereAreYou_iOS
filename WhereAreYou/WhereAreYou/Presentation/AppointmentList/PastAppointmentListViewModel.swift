//
//  PastAppointmentListViewModel.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/21/26.
//

import Foundation
import Combine

// MARK: - 지난 약속 화면의 데이터
//       - 약속 시각이 지났고, 지난 지 30일 이내인 약속만 보관

final class PastAppointmentListViewModel {

    private(set) var pastAppointments: [AppointmentListItem] = []

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
                let now = Date()
                let appointments = try await fetchMyAppointmentsUseCase.execute(
                    from: now.addingTimeInterval(-30 * 24 * 60 * 60),
                    to: now
                )
                // TODO: 약속 알림 연동 시 users.appointmentsNotification 값으로 교체
                pastAppointments = appointments.reversed().map {
                    AppointmentListItem(
                        appointment: $0,
                        isNotificationEnabled: item(id: $0.id)?.isNotificationEnabled ?? true
                    )
                }
                loadResult = .success(())
            } catch {
                loadResult = .failure(error)
            }
        }
    }

    func toggleNotification(id: String) {
        guard let index = pastAppointments.firstIndex(where: { $0.id == id }) else { return }
        pastAppointments[index] = toggledNotification(of: pastAppointments[index])
    }

    func item(id: String) -> AppointmentListItem? {
        pastAppointments.first { $0.id == id }
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
                pastAppointments.removeAll { $0.id == id }
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
