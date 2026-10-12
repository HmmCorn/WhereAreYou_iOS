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
    private var isCreating = false
    private var placeDomain: Place?

    @Published private(set) var appointmentDate: Date?
    @Published private(set) var place: PlaceInfo?
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
        placeDomain = place
        self.place = PlaceInfo(place: place)
    }

    func create() {
        guard !isCreating, !hasCreated else { return }
        isCreating = true
        if appointmentTitle.isEmpty { appointmentTitle = "약속" }

        // TODO: 약속 날짜 필수화 때 appointmentDate를 필수로 바꾸고 기본값을 없앤다
        let dateTime = appointmentDate ?? Date()
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let appointment = try await self.createAppointmentUseCase.execute(
                    name: self.appointmentTitle,
                    dateTime: dateTime,
                    place: self.placeDomain
                )
                self.isCreating = false
                self.id = appointment.id
                self.code = appointment.code
                self.hasCreated = true
            } catch {
                self.isCreating = false
                // TODO: 서버 작업 후 실패 케이스 정리해 사용자에게 표시할 실패 텍스트 추가 예정
            }
        }
    }

    func makeAppointmentInfo() -> AppointmentInfo {
        AppointmentInfo(
            id: id ?? "",
            code: code ?? "",
            title: appointmentTitle,
            date: appointmentDate,
            location: placeDomain.map { AppointmentLocation(place: $0) },
            participants: []
        )
    }

}
