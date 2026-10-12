//
//  HomeViewModel.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/16/26.
//

import Foundation

final class HomeViewModel {

    private(set) var upcomingAppointments: [UpcomingAppointment] = []

    private let joinAppointmentUseCase: JoinAppointmentUseCase

    init(joinAppointmentUseCase: JoinAppointmentUseCase) {
        self.joinAppointmentUseCase = joinAppointmentUseCase
        loadDummyData()
    }

    func joinAppointment(code: String, completion: @escaping (Result<AppointmentInfo, Error>) -> Void) {
        Task { @MainActor in
            do {
                let appointment = try await joinAppointmentUseCase.execute(code: code)
                completion(.success(AppointmentInfo(appointment: appointment)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func loadDummyData() {
        upcomingAppointments = [
            UpcomingAppointment(
                id: "1",
                title: "고등학교 친구들과 저녁",
                participantCount: 5,
                location: AppointmentLocation(
                    title: "고기굽는방앗간 이수역점",
                    address: "",
                    coordinate: Coordinate(latitude: 0, longitude: 0)
                ),
                date: Date().addingTimeInterval(10 * 60 * 60)
            ),
            UpcomingAppointment(
                id: "2",
                title: "동아리 MT",
                participantCount: 12,
                location: AppointmentLocation(
                    title: "강촌 펜션",
                    address: "",
                    coordinate: Coordinate(latitude: 0, longitude: 0)
                ),
                date: Date().addingTimeInterval(30 * 60 * 60)
            ),
            UpcomingAppointment(
                id: "3",
                title: "생일 파티",
                participantCount: 8,
                location: AppointmentLocation(
                    title: "홍대 파티룸",
                    address: "",
                    coordinate: Coordinate(latitude: 0, longitude: 0)
                ),
                date: Date().addingTimeInterval(3 * 60 * 60)
            )
        ]
        .sorted { $0.date < $1.date }
    }

}
