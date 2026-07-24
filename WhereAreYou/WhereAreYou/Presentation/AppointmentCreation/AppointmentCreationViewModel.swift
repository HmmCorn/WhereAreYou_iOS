//
//  AppointmentCreationViewModel.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-24.
//

import Foundation
import Combine

final class AppointmentCreationViewModel {

    @Published private(set) var appointmentTitle: String
    @Published private(set) var appointmentDate: Date?
    @Published private(set) var appointmentPlace: Place?
    @Published private(set) var code: String?
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
        // 약속 고유 코드 생성하고 use case 통해 서버에 신규 약속 업로드
        // 약속 잘 저장되었다는 서버 응답 받고 hasCreated = true로
    }

}
