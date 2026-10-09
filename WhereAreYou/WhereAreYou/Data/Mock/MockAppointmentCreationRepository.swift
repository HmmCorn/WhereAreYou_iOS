//
//  MockAppointmentCreationRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-24.
//

import Foundation

final class MockAppointmentCreationRepository: AppointmentCreationRepository {

    func createAppointment(
        title: String,
        date: Date?,
        place: Place?,
        completion: @escaping (Result<Appointment, Error>) -> Void
    ) {
        let code = String(UUID().uuidString.prefix(8))
        let appointment = Appointment(
            id: UUID().uuidString,
            code: code,
            name: title,
            dateTime: date ?? Date(),
            place: place,
            participants: [],
            routes: [:],
            placeVoteStatus: [:]
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(appointment))
        }
    }

}
