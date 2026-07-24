//
//  AppointmentCreationViewModel.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-24.
//

import Foundation
import Combine

final class AppointmentCreationViewModel {

    private let createAppointmentUseCase: CreateAppointmentUseCase

    private var appointmentTitle: String
    private var id: String?
    private var code: String?

    @Published private(set) var appointmentDate: Date?
    @Published private(set) var appointmentPlace: Place?
    @Published private(set) var hasCreated: Bool = false

    init(createAppointmentUseCase: CreateAppointmentUseCase) {
        self.createAppointmentUseCase = createAppointmentUseCase
        appointmentTitle = "약속"
    }

    func setTitle(_ title: String) {
        appointmentTitle = title
    }

    func setDate(_ date: Date) {
        appointmentDate = date
    }

    func setPlace(_ place: Place) {
        appointmentPlace = place
    }

    func create() {
        if appointmentTitle.isEmpty { appointmentTitle = "약속" }

        createAppointmentUseCase.execute(
            title: appointmentTitle,
            date: appointmentDate,
            place: appointmentPlace
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let appointment):
                self.id = appointment.id
                self.code = appointment.code
                self.hasCreated = true
            case .failure:
                break
            }
        }
    }

    func makeAppointmentInfo() -> AppointmentInfo {
        AppointmentInfo(
            id: id ?? "",
            code: code ?? "",
            title: appointmentTitle,
            date: appointmentDate,
            location: appointmentPlace.map {
                AppointmentLocation(
                    title: $0.name,
                    address: $0.address,
                    coordinate: $0.coordinate
                )
            },
            participants: []
        )
    }

}
