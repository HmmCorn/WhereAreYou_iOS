//
//  FirebaseAppointmentRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-10-29.
//

import Foundation
import FirebaseFirestore
import FirebaseFunctions

/// AppointmentRepository의 Firebase 구현체 — 생성·참여·나가기는 Functions callable로 서버가 처리하고,
/// 조회·정보 수정은 Firestore에 직접 한다
final class FirebaseAppointmentRepository: AppointmentRepository {

    private let db = Firestore.firestore()
    private let functions = Functions.app
    private let authRepository: AuthRepository
    private let userRepository: UserRepository

    init(authRepository: AuthRepository, userRepository: UserRepository) {
        self.authRepository = authRepository
        self.userRepository = userRepository
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
        do {
            let snapshot = try await db.collection("appointments").document(appointmentID).getDocument()
            guard let data = snapshot.data(),
                  let dto = AppointmentDocumentDTO(id: snapshot.documentID, data: data) else {
                throw AppError.notFound
            }
            let usersByID = try await userRepository.fetchUsers(userIDs: Set(dto.participantIDs))
            return dto.toDomain(usersByID: usersByID)
        } catch let error as AppError {
            throw error
        } catch {
            throw FirebaseErrorMapper.map(error)
        }
    }

    func fetchMyAppointments(from: Date, to: Date?) async throws -> [Appointment] {
        guard let currentUserID = authRepository.currentUserID else {
            throw AppError.notAuthenticated
        }

        var query = db.collection("appointments")
            .whereField("participantIDs", arrayContains: currentUserID)
            .whereField("dateTime", isGreaterThanOrEqualTo: Timestamp(date: from))
        if let to {
            query = query.whereField("dateTime", isLessThan: Timestamp(date: to))
        }

        do {
            let snapshot = try await query.order(by: "dateTime").getDocuments()
            let dtos = snapshot.documents.compactMap {
                AppointmentDocumentDTO(id: $0.documentID, data: $0.data())
            }
            // 약속마다 조회하지 않도록 참여자를 모아 한 번에 읽는다
            let usersByID = try await userRepository.fetchUsers(userIDs: Set(dtos.flatMap(\.participantIDs)))
            return dtos.map { $0.toDomain(usersByID: usersByID) }
        } catch let error as AppError {
            throw error
        } catch {
            throw FirebaseErrorMapper.map(error)
        }
    }

    func updateAppointment(
        appointmentID: String,
        name: String?,
        dateTime: Date?,
        place: Place?
    ) async throws -> Appointment {
        var fields: [String: Any] = [:]
        if let name {
            fields["name"] = name
        }
        if let dateTime {
            fields["dateTime"] = Timestamp(date: dateTime)
        }
        if let place {
            fields["place"] = AppointmentDTO.data(from: place)
        }

        if !fields.isEmpty {
            do {
                try await db.collection("appointments").document(appointmentID).updateData(fields)
            } catch {
                throw FirebaseErrorMapper.map(error)
            }
        }
        return try await fetchAppointment(appointmentID: appointmentID)
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
