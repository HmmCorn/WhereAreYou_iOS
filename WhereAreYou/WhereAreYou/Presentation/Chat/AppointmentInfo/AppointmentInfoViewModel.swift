//
//  AppointmentInfoViewModel.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-06.
//

import Foundation
import Combine

final class AppointmentInfoViewModel {

    @Published private(set) var appointmentInfo: AppointmentInfo?
    @Published private(set) var leaveResult: Result<Void, Error>?

    private let appointmentID: String
    private let fetchAppointmentInfoUseCase: FetchAppointmentInfoUseCase
    private let updateAppointmentInfoUseCase: UpdateAppointmentInfoUseCase
    private let leaveAppointmentUseCase: LeaveAppointmentUseCase

    init(
        appointmentID: String,
        fetchAppointmentInfoUseCase: FetchAppointmentInfoUseCase,
        updateAppointmentInfoUseCase: UpdateAppointmentInfoUseCase,
        leaveAppointmentUseCase: LeaveAppointmentUseCase
    ) {
        self.appointmentID = appointmentID
        self.fetchAppointmentInfoUseCase = fetchAppointmentInfoUseCase
        self.updateAppointmentInfoUseCase = updateAppointmentInfoUseCase
        self.leaveAppointmentUseCase = leaveAppointmentUseCase
    }

    func fetchAppointmentInfo() {
        Task { @MainActor [weak self] in
            guard let self,
                  let appointment = try? await self.fetchAppointmentInfoUseCase.execute(appointmentID: self.appointmentID)
            else { return }
            self.appointmentInfo = AppointmentInfo(appointment: appointment)
        }
    }

    func updateNameIfChanged(_ name: String) {
        guard let current = appointmentInfo, name != current.title else { return }
        update(name: name, date: nil, place: nil)
    }

    func updateDate(_ date: Date) {
        update(name: nil, date: date, place: nil)
    }

    func updatePlace(_ place: Place) {
        update(name: nil, date: nil, place: place)
    }

    func leave() {
        Task { @MainActor in
            do {
                try await leaveAppointmentUseCase.execute(appointmentID: appointmentID)
                leaveResult = .success(())
            } catch {
                leaveResult = .failure(error)
            }
        }
    }

    private func update(name: String?, date: Date?, place: Place?) {
        Task { @MainActor [weak self] in
            guard let self,
                  let appointment = try? await self.updateAppointmentInfoUseCase.execute(
                      appointmentID: self.appointmentID,
                      name: name,
                      dateTime: date,
                      place: place
                  )
            else { return }
            self.appointmentInfo = AppointmentInfo(appointment: appointment)
        }
    }

}
