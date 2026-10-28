//
//  MockAppointmentRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-06.
//

import Foundation

/// 서버 연결 전 약속 저장소 — 고정 약속 하나를 돌려주고, 정보 수정은 인스턴스 안에만 반영한다.
/// "나"는 로그인한 사용자 ID로 넣어 경로·참여자 화면에서 내 항목을 찾을 수 있게 한다
final class MockAppointmentRepository: AppointmentRepository {

    /// true면 약속 시각을 5분 전으로 당긴다 — 약속 시간이 지난 상태의 라이브 액티비티 확인용.
    /// 내 경로도 같이 당겨야 해서 MockAppointmentRouteRepository가 함께 읽는다
    static var startsAfterAppointmentTime = false
    static let place = Place(
        id: "place_starbucks_gangnam",
        name: "스타벅스 강남역점",
        address: "서울 강남구 강남대로 396",
        coordinate: Coordinate(latitude: 37.4979, longitude: 127.0276),
        type: .cafe
    )
    /// 로그인 정보가 없을 때 쓰는 내 ID
    static let fallbackCurrentUserID = "user_me"
    private static let mockCode = "MOCK1234"

    private let authRepository: AuthRepository
    private var storedAppointments: [String: Appointment] = [:]

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func createAppointment(name: String, dateTime: Date, place: Place?) async throws -> Appointment {
        try await Task.sleep(for: .milliseconds(500))
        let appointment = Appointment(
            id: UUID().uuidString,
            code: String(UUID().uuidString.prefix(8)),
            name: name,
            dateTime: dateTime,
            place: place,
            participants: []
        )
        storedAppointments[appointment.id] = appointment
        return appointment
    }

    func joinAppointment(code: String) async throws -> Appointment {
        try await Task.sleep(for: .milliseconds(500))
        guard code == Self.mockCode else {
            throw AppError.notFound
        }
        return storedAppointment(appointmentID: "appointment_joined")
    }

    func leaveAppointment(appointmentID: String) async throws {
        try await Task.sleep(for: .milliseconds(300))
        storedAppointments[appointmentID] = nil
    }

    func fetchAppointment(appointmentID: String) async throws -> Appointment {
        try await Task.sleep(for: .milliseconds(300))
        return storedAppointment(appointmentID: appointmentID)
    }

    func updateAppointment(
        appointmentID: String,
        name: String?,
        dateTime: Date?,
        place: Place?
    ) async throws -> Appointment {
        try await Task.sleep(for: .milliseconds(200))
        guard let current = storedAppointments[appointmentID] else {
            throw AppError.notFound
        }

        let updated = Appointment(
            id: current.id,
            code: current.code,
            name: name ?? current.name,
            dateTime: dateTime ?? current.dateTime,
            place: place ?? current.place,
            participants: current.participants
        )
        storedAppointments[appointmentID] = updated
        return updated
    }

    private func storedAppointment(appointmentID: String) -> Appointment {
        if let stored = storedAppointments[appointmentID] {
            return stored
        }
        let appointment = makeMockAppointment(appointmentID: appointmentID)
        storedAppointments[appointmentID] = appointment
        return appointment
    }

    private func makeMockAppointment(appointmentID: String) -> Appointment {
        let timelineBase = Self.startsAfterAppointmentTime ? Date().addingTimeInterval(-30 * 60) : Date()

        return Appointment(
            id: appointmentID,
            code: Self.mockCode,
            name: "고기굽는방앗간 이수역점",
            dateTime: timelineBase.addingTimeInterval(25 * 60),
            place: Self.place,
            participants: makeParticipants()
        )
    }

    private func makeParticipants() -> [User] {
        let me = User(
            id: authRepository.currentUserID ?? Self.fallbackCurrentUserID,
            nickname: "나",
            profileImage: "shark",
            defaultTransportMode: .car,
            locationSharingScope: .onlyDuringAppointment,
            isNotificationEnabled: true,
            appointmentsNotification: [:]
        )
        let others: [(id: String, nickname: String, profileImage: String, transportMode: TransportType)] = [
            ("user_minji", "김민지", "turtle", .transit),
            ("user_seoyeon", "이서연", "shark", .car),
            ("user_junwoo", "박준우", "turtle", .transit),
            ("user_gildong", "최길동", "shark", .walk),
            ("user_subin", "정수빈", "turtle", .car),
        ]

        return [me] + others.map {
            User(
                id: $0.id,
                nickname: $0.nickname,
                profileImage: $0.profileImage,
                defaultTransportMode: $0.transportMode,
                locationSharingScope: .onlyDuringAppointment,
                isNotificationEnabled: true,
                appointmentsNotification: [:]
            )
        }
    }

}
