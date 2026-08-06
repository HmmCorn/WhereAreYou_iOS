//
//  ChatViewModel.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-30.
//

import Foundation
import Combine

/// 채팅 화면 상태 관리 — 메시지 조회/전송, 위치/장소 공유, display item 빌드
final class ChatViewModel {

    static let currentUserID = "me"

    @Published private(set) var displayItems: [ChatDisplayItem] = []
    @Published private(set) var canSend = false
    @Published private(set) var isEmpty = false

    private(set) var appointmentInfo: AppointmentInfo
    private var messages: [Chat] = []

    private let fetchMessagesUseCase: FetchMessagesUseCase
    private let sendMessageUseCase: SendMessageUseCase
    private let getCurrentLocationUseCase: GetCurrentLocationUseCase
    private let shareLocationUseCase: ShareLocationUseCase
    private let sharePlaceUseCase: SharePlaceUseCase

    init(
        appointmentInfo: AppointmentInfo,
        fetchMessagesUseCase: FetchMessagesUseCase,
        sendMessageUseCase: SendMessageUseCase,
        getCurrentLocationUseCase: GetCurrentLocationUseCase,
        shareLocationUseCase: ShareLocationUseCase,
        sharePlaceUseCase: SharePlaceUseCase
    ) {
        self.appointmentInfo = appointmentInfo
        self.fetchMessagesUseCase = fetchMessagesUseCase
        self.sendMessageUseCase = sendMessageUseCase
        self.getCurrentLocationUseCase = getCurrentLocationUseCase
        self.shareLocationUseCase = shareLocationUseCase
        self.sharePlaceUseCase = sharePlaceUseCase
    }

    func fetchMessages() {
        fetchMessagesUseCase.execute(appointmentID: appointmentInfo.id) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                if case .success(let messages) = result {
                    self.messages = messages
                    self.displayItems = self.buildDisplayItems(from: messages)
                }
            }
        }
    }

    func sendMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        sendMessageUseCase.execute(
            appointmentID: appointmentInfo.id,
            content: trimmed
        ) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                if case .success(let message) = result {
                    self.messages.append(message)
                    self.displayItems = self.buildDisplayItems(from: self.messages)
                }
            }
        }
    }

    func updateCanSend(text: String) {
        canSend = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Location Share

    func fetchCurrentLocation(completion: @escaping (Coordinate, String) -> Void) {
        getCurrentLocationUseCase.execute { result in
            DispatchQueue.main.async {
                if case .success(let coordinate) = result {
                    // TODO: CLGeocoder로 실제 주소 변환
                    let address = "서울특별시 중구 세종대로 110"
                    completion(coordinate, address)
                }
            }
        }
    }

    func shareLocation(coordinate: Coordinate) {
        shareLocationUseCase.execute(
            appointmentID: appointmentInfo.id,
            coordinate: coordinate
        ) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                if case .success(let message) = result {
                    self.messages.append(message)
                    self.displayItems = self.buildDisplayItems(from: self.messages)
                }
            }
        }
    }

    // MARK: - Place Share

    func sharePlace(_ place: Place) {
        sharePlaceUseCase.execute(
            appointmentID: appointmentInfo.id,
            place: place
        ) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                if case .success(let message) = result {
                    self.messages.append(message)
                    self.displayItems = self.buildDisplayItems(from: self.messages)
                }
            }
        }
    }

}

// MARK: - Display Item Builder

private extension ChatViewModel {

    /// 내 메시지는 오른쪽, 타인 메시지는 왼쪽 — 발신자가 바뀌면 프로필 표시, 같은 발신자·같은 분(minute)이면 마지막에만 시간 표시
    func buildDisplayItems(from messages: [Chat]) -> [ChatDisplayItem] {
        isEmpty = messages.isEmpty

        var items: [ChatDisplayItem] = []
        var sharedPlaceIDs: Set<String> = []

        for (index, message) in messages.enumerated() {
            let isMe = message.sender.id == Self.currentUserID
            let showTime = shouldShowTime(at: index, in: messages)
            let timeText = showTime ? message.sentAt.koreanTimeString : nil

            let bubbleContent: String
            let contentType: ChatBubbleItem.BubbleContentType
            switch message.contentType {
            case .text(let text):
                bubbleContent = text
                contentType = .text
            case .locationShare:
                bubbleContent = "📌 위치를 공유했어요"
                contentType = .locationShare
            case .placeShare(let place):
                bubbleContent = place.name
                let isDuplicate = sharedPlaceIDs.contains(place.id)
                sharedPlaceIDs.insert(place.id)
                contentType = .placeShare(placeName: place.name, placeAddress: place.address, isDuplicate: isDuplicate)
            }

            let bubbleItem = ChatBubbleItem(
                id: message.id,
                senderID: message.sender.id,
                senderNickname: message.sender.nickname,
                senderProfileImage: message.sender.profileImage.lastPathComponent,
                content: bubbleContent,
                timeText: timeText,
                sentAt: message.sentAt,
                contentType: contentType
            )

            if isMe {
                items.append(.myMessage(bubbleItem))
            } else {
                let showProfile = shouldShowProfile(at: index, in: messages)
                items.append(.otherMessage(bubbleItem, showProfile: showProfile))
            }
        }

        return items
    }

    /// 같은 발신자가 같은 분(minute) 안에 연속 전송한 경우 마지막 메시지에만 시간 표시
    func shouldShowTime(at index: Int, in messages: [Chat]) -> Bool {
        guard index + 1 < messages.count else { return true }
        let current = messages[index]
        let next = messages[index + 1]
        if current.sender.id != next.sender.id { return true }
        return !Calendar.current.isDate(current.sentAt, equalTo: next.sentAt, toGranularity: .minute)
    }

    /// 직전 메시지와 발신자가 다르면 프로필(이미지+이름) 표시
    func shouldShowProfile(at index: Int, in messages: [Chat]) -> Bool {
        guard index > 0 else { return true }
        let current = messages[index]
        let previous = messages[index - 1]
        return current.sender.id != previous.sender.id
    }

}
