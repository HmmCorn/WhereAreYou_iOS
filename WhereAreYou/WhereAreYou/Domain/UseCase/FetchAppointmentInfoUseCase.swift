//
//  FetchAppointmentInfoUseCase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-06.
//

final class FetchAppointmentInfoUseCase {

    private let repository: AppointmentInfoRepository

    init(repository: AppointmentInfoRepository) {
        self.repository = repository
    }

    func execute(
        appointmentID: String,
        completion: @escaping (Result<Appointment, Error>) -> Void
    ) {
        repository.fetchAppointmentInfo(appointmentID: appointmentID, completion: completion)
    }

}
