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

    init(
        appointmentID: String,
        fetchAppointmentInfoUseCase: FetchAppointmentInfoUseCase
    ) {
        self.appointmentID = appointmentID
        self.fetchAppointmentInfoUseCase = fetchAppointmentInfoUseCase
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
