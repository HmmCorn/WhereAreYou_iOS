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

    private let appointmentID: String
    private let fetchAppointmentInfoUseCase: FetchAppointmentInfoUseCase
    private let updateAppointmentInfoUseCase: UpdateAppointmentInfoUseCase

    init(
        appointmentID: String,
        fetchAppointmentInfoUseCase: FetchAppointmentInfoUseCase,
        updateAppointmentInfoUseCase: UpdateAppointmentInfoUseCase
    ) {
        self.appointmentID = appointmentID
        self.fetchAppointmentInfoUseCase = fetchAppointmentInfoUseCase
        self.updateAppointmentInfoUseCase = updateAppointmentInfoUseCase
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
