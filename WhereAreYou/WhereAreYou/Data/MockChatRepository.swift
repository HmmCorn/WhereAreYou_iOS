//
//  MockChatRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-30.
//

import Foundation

final class MockChatRepository: ChatRepository {

    private static let currentUserID = "me"

    private var messages: [String: [Chat]] = [:]
    private var nextID = 100

    func fetchMessages(
        appointmentID: String,
        completion: @escaping (Result<[Chat], Error>) -> Void
    ) {
        if messages[appointmentID] == nil {
            messages[appointmentID] = Self.makeMockMessages(appointmentID: appointmentID)
        }

        let result = messages[appointmentID] ?? []
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            completion(.success(result))
        }
    }

    func sendMessage(
        appointmentID: String,
        content: String,
        completion: @escaping (Result<Chat, Error>) -> Void
    ) {
        let message = Chat(
            id: "\(nextID)",
            appointmentID: appointmentID,
            sender: Self.currentUser,
            text: content,
            sentAt: Date()
        )
        nextID += 1

        if messages[appointmentID] == nil {
            messages[appointmentID] = []
        }
        messages[appointmentID]?.append(message)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            completion(.success(message))
        }
    }

    private static let currentUser = User(
        id: currentUserID,
        nickname: "나",
        profileImage: URL(string: "https://placeholder")!,
        defaultTransportMode: .transit,
        locationSharingScope: .onlyDuringAppointment,
        isNotificationEnabled: true,
        appointmentsNotification: [:]
    )

    private static let user2 = User(
        id: "user2",
        nickname: "김길동",
        profileImage: URL(string: "shark")!,
        defaultTransportMode: .transit,
        locationSharingScope: .onlyDuringAppointment,
        isNotificationEnabled: true,
        appointmentsNotification: [:]
    )

    private static let user3 = User(
        id: "user3",
        nickname: "홍길동",
        profileImage: URL(string: "turtle")!,
        defaultTransportMode: .transit,
        locationSharingScope: .onlyDuringAppointment,
        isNotificationEnabled: true,
        appointmentsNotification: [:]
    )

    private static func makeMockMessages(appointmentID: String) -> [Chat] {
        let calendar = Calendar.current
        let now = Date()
        let baseDate = calendar.date(byAdding: .hour, value: -1, to: now)!

        return [
            Chat(
                id: "1", appointmentID: appointmentID,
                sender: currentUser, text: "텍스트 텍스트",
                sentAt: calendar.date(byAdding: .minute, value: 0, to: baseDate)!
            ),
            Chat(
                id: "2", appointmentID: appointmentID,
                sender: user2, text: "안녕하세요! 오늘 약속 장소 확인했어요",
                sentAt: calendar.date(byAdding: .minute, value: 2, to: baseDate)!
            ),
            Chat(
                id: "3", appointmentID: appointmentID,
                sender: user3, text: "저도 확인했습니다",
                sentAt: calendar.date(byAdding: .minute, value: 2, to: baseDate)!
            ),
            Chat(
                id: "4", appointmentID: appointmentID,
                sender: user3, text: "근데 장소가 좀 멀어서 일찍 출발해야 할 것 같아요",
                sentAt: calendar.date(byAdding: .minute, value: 2, to: baseDate)!
            ),
            Chat(
                id: "5", appointmentID: appointmentID,
                sender: user3, text: "다들 몇 시에 출발하시나요?",
                sentAt: calendar.date(byAdding: .minute, value: 3, to: baseDate)!
            ),
            Chat(
                id: "6", appointmentID: appointmentID,
                sender: currentUser, text: "저는 2시에 출발할 예정이에요",
                sentAt: calendar.date(byAdding: .minute, value: 3, to: baseDate)!
            ),
        ]
    }

}
