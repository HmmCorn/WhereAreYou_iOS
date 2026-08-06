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

    func sendChat(
        appointmentID: String,
        contentType: ChatContentType,
        completion: @escaping (Result<Chat, Error>) -> Void
    ) {
        let summaryText: String?
        switch contentType {
        case .text(let text):
            summaryText = text
        case .locationShare:
            summaryText = "📌 위치를 공유했어요"
        case .placeShare(let place):
            summaryText = "\(place.name) 장소를 공유했어요"
        }

        let message = Chat(
            id: "\(nextID)",
            appointmentID: appointmentID,
            sender: Self.currentUser,
            sentAt: Date(),
            contentType: contentType,
            summaryText: summaryText
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

    private static let gangnamPlace = Place(
        id: "gangnam", name: "강남역",
        address: "서울 강남구 강남대로 396",
        coordinate: Coordinate(latitude: 37.4979, longitude: 127.0276),
        type: .subway
    )

    private static let hongdaePlace = Place(
        id: "hongdae", name: "홍대입구역",
        address: "서울 마포구 양화로 160",
        coordinate: Coordinate(latitude: 37.5571, longitude: 126.9236),
        type: .subway
    )

    private static func makeMockMessages(appointmentID: String) -> [Chat] {
        let calendar = Calendar.current
        let now = Date()
        let baseDate = calendar.date(byAdding: .hour, value: -1, to: now)!

        return [
            Chat(
                id: "1", appointmentID: appointmentID,
                sender: currentUser,
                sentAt: calendar.date(byAdding: .minute, value: 0, to: baseDate)!,
                contentType: .text("텍스트 텍스트"),
                summaryText: nil
            ),
            Chat(
                id: "2", appointmentID: appointmentID,
                sender: user2,
                sentAt: calendar.date(byAdding: .minute, value: 2, to: baseDate)!,
                contentType: .text("안녕하세요! 오늘 약속 장소 확인했어요"),
                summaryText: nil
            ),
            Chat(
                id: "3", appointmentID: appointmentID,
                sender: user3,
                sentAt: calendar.date(byAdding: .minute, value: 2, to: baseDate)!,
                contentType: .text("저도 확인했습니다"),
                summaryText: nil
            ),
            Chat(
                id: "4", appointmentID: appointmentID,
                sender: user3,
                sentAt: calendar.date(byAdding: .minute, value: 2, to: baseDate)!,
                contentType: .text("근데 장소가 좀 멀어서 일찍 출발해야 할 것 같아요"),
                summaryText: nil
            ),
            Chat(
                id: "5", appointmentID: appointmentID,
                sender: user3,
                sentAt: calendar.date(byAdding: .minute, value: 3, to: baseDate)!,
                contentType: .text("다들 몇 시에 출발하시나요?"),
                summaryText: nil
            ),
            Chat(
                id: "6", appointmentID: appointmentID,
                sender: currentUser,
                sentAt: calendar.date(byAdding: .minute, value: 3, to: baseDate)!,
                contentType: .text("저는 2시에 출발할 예정이에요"),
                summaryText: nil
            ),
            Chat(
                id: "7", appointmentID: appointmentID,
                sender: user2,
                sentAt: calendar.date(byAdding: .minute, value: 5, to: baseDate)!,
                contentType: .locationShare(Coordinate(latitude: 37.5100, longitude: 127.0300)),
                summaryText: "📌 위치를 공유했어요"
            ),
            Chat(
                id: "8", appointmentID: appointmentID,
                sender: user2,
                sentAt: calendar.date(byAdding: .minute, value: 6, to: baseDate)!,
                contentType: .placeShare(gangnamPlace),
                summaryText: "강남역 장소를 공유했어요"
            ),
            Chat(
                id: "9", appointmentID: appointmentID,
                sender: user3,
                sentAt: calendar.date(byAdding: .minute, value: 7, to: baseDate)!,
                contentType: .locationShare(Coordinate(latitude: 37.5500, longitude: 126.9200)),
                summaryText: "📌 위치를 공유했어요"
            ),
            Chat(
                id: "10", appointmentID: appointmentID,
                sender: user3,
                sentAt: calendar.date(byAdding: .minute, value: 8, to: baseDate)!,
                contentType: .placeShare(hongdaePlace),
                summaryText: "홍대입구역 장소를 공유했어요"
            ),
            Chat(
                id: "11", appointmentID: appointmentID,
                sender: user3,
                sentAt: calendar.date(byAdding: .minute, value: 8, to: baseDate)!,
                contentType: .text("홍대 쪽이 중간이라 좋을 것 같아요!"),
                summaryText: nil
            ),
            Chat(
                id: "12", appointmentID: appointmentID,
                sender: user3,
                sentAt: calendar.date(byAdding: .minute, value: 10, to: baseDate)!,
                contentType: .placeShare(gangnamPlace),
                summaryText: "강남역 장소를 공유했어요"
            ),
        ]
    }

}
