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
        fetchAppointmentInfoUseCase.execute(appointmentID: appointmentID) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let appointment) = result {
                    self?.appointmentInfo = self?.buildAppointmentInfo(from: appointment)
                }
            }
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
        updateAppointmentInfoUseCase.execute(
            appointmentID: appointmentID,
            name: name,
            date: date,
            place: place
        ) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let appointment) = result {
                    self?.appointmentInfo = self?.buildAppointmentInfo(from: appointment)
                }
            }
        }
    }

    private func buildAppointmentInfo(from appointment: Appointment) -> AppointmentInfo {
        let location = appointment.place.map {
            AppointmentLocation(title: $0.name, address: $0.address, coordinate: $0.coordinate)
        }
        let participants = appointment.participants.map {
            Participant(id: $0.id, nickname: $0.nickname, profileImage: $0.profileImage.lastPathComponent)
        }
        return AppointmentInfo(
            id: appointment.id,
            code: appointment.code,
            title: appointment.name,
            date: appointment.dateTime,
            location: location,
            participants: participants
        )
    }

}
