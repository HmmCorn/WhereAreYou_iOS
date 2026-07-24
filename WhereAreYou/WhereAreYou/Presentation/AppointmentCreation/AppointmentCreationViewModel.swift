//
//  AppointmentCreationViewModel.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-24.
//

import Foundation
import Combine

final class AppointmentCreationViewModel {

    private(set) var appointmentTitle: String
    private(set) var code: String?

    @Published private(set) var appointmentDate: Date?
    @Published private(set) var appointmentPlace: Place?
    @Published private(set) var hasCreated: Bool = false

    init() {
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

}
