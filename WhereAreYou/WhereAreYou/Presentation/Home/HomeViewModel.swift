//
//  HomeViewModel.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/16/26.
//

import Foundation
import Combine

final class HomeViewModel {

    private(set) var upcomingAppointments: [UpcomingAppointment] = []
    @Published private(set) var loadResult: Result<Void, Error>?
    @Published private(set) var joinResult: Result<AppointmentInfo, Error>?

    private let fetchMyAppointmentsUseCase: FetchMyAppointmentsUseCase
    private let joinAppointmentUseCase: JoinAppointmentUseCase

    init(
        fetchMyAppointmentsUseCase: FetchMyAppointmentsUseCase,
        joinAppointmentUseCase: JoinAppointmentUseCase
    ) {
        self.fetchMyAppointmentsUseCase = fetchMyAppointmentsUseCase
        self.joinAppointmentUseCase = joinAppointmentUseCase
    }

    func loadAppointments() {
        Task { @MainActor in
            do {
                let appointments = try await fetchMyAppointmentsUseCase.execute(from: Date(), to: nil)
                upcomingAppointments = appointments.map { UpcomingAppointment(appointment: $0) }
                loadResult = .success(())
            } catch {
                loadResult = .failure(error)
            }
        }
    }

    func joinAppointment(code: String) {
        Task { @MainActor in
            do {
                let appointment = try await joinAppointmentUseCase.execute(code: code)
                joinResult = .success(AppointmentInfo(appointment: appointment))
            } catch {
                joinResult = .failure(error)
            }
        }
    }

}
