//
//  FirebaseAppointmentRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-10-29.
//

import Foundation
import FirebaseFunctions

/// AppointmentRepository의 Firebase 구현체 — 생성·참여·나가기는 Functions callable로 서버가 처리한다.
/// 조회·정보 수정은 Firestore 연동 전까지 Mock에 맡긴다
final class FirebaseAppointmentRepository: AppointmentRepository {

    private let functions = Functions.app
    // TODO: 조회·정보 수정 Firestore 연동 후 제거
    private let mockRepository: MockAppointmentRepository

    init(mockRepository: MockAppointmentRepository) {
        self.mockRepository = mockRepository
    }

    func createAppointment(name: String, dateTime: Date, place: Place?) async throws -> Appointment {
        var request: [String: Any] = [
            "name": name,
            "dateTime": (dateTime.timeIntervalSince1970 * 1000).rounded()
        ]
        if let place {
            request["place"] = AppointmentDTO.data(from: place)
        }
        return try await callAppointment("createAppointment", request: request)
    }

    func joinAppointment(code: String) async throws -> Appointment {
        try await callAppointment("joinAppointment", request: ["code": code])
    }

    func leaveAppointment(appointmentID: String) async throws {
        do {
            _ = try await functions.httpsCallable("leaveAppointment").call(["appointmentID": appointmentID])
        } catch {
            throw FirebaseErrorMapper.map(error)
        }
    }

    func fetchAppointment(appointmentID: String) async throws -> Appointment {
        try await mockRepository.fetchAppointment(appointmentID: appointmentID)
    }

    func updateAppointment(
        appointmentID: String,
        name: String?,
        dateTime: Date?,
        place: Place?
    ) async throws -> Appointment {
        try await mockRepository.updateAppointment(
            appointmentID: appointmentID,
            name: name,
            dateTime: dateTime,
            place: place
        )
    }

    /// 약속 응답을 돌려주는 callable을 호출한다
    private func callAppointment(_ name: String, request: [String: Any]) async throws -> Appointment {
        let result: HTTPSCallableResult
        do {
            result = try await functions.httpsCallable(name).call(request)
        } catch {
            throw FirebaseErrorMapper.map(error)
        }
        guard let dto = AppointmentDTO(data: result.data) else {
            throw AppError.notFound
        }
        return dto.toDomain()
    }

}
