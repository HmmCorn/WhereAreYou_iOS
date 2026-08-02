//
//  ChatViewModel.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-30.
//

import Foundation
import Combine

final class ChatViewModel {

    static let currentUserID = "me"

    @Published private(set) var displayItems: [ChatDisplayItem] = []
    @Published private(set) var canSend = false

    private(set) var appointmentInfo: AppointmentInfo
    private var messages: [Chat] = []

    private let fetchMessagesUseCase: FetchMessagesUseCase
    private let sendMessageUseCase: SendMessageUseCase

    init(
        appointmentInfo: AppointmentInfo,
        fetchMessagesUseCase: FetchMessagesUseCase,
        sendMessageUseCase: SendMessageUseCase
    ) {
        self.appointmentInfo = appointmentInfo
        self.fetchMessagesUseCase = fetchMessagesUseCase
        self.sendMessageUseCase = sendMessageUseCase
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

}

// MARK: - Display Item Builder

private extension ChatViewModel {

    func buildDisplayItems(from messages: [Chat]) -> [ChatDisplayItem] {
        var items: [ChatDisplayItem] = []

        for (index, message) in messages.enumerated() {
            let isMe = message.sender.id == Self.currentUserID
            let showTime = shouldShowTime(at: index, in: messages)
            let timeText = showTime ? message.sentAt.koreanTimeString : nil

            let bubbleItem = ChatBubbleItem(
                id: message.id,
                senderID: message.sender.id,
                senderNickname: message.sender.nickname,
                senderProfileImage: message.sender.profileImage.lastPathComponent,
                content: message.text,
                timeText: timeText,
                sentAt: message.sentAt
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

    func shouldShowTime(at index: Int, in messages: [Chat]) -> Bool {
        guard index + 1 < messages.count else { return true }
        let current = messages[index]
        let next = messages[index + 1]
        if current.sender.id != next.sender.id { return true }
        return !Calendar.current.isDate(current.sentAt, equalTo: next.sentAt, toGranularity: .minute)
    }

    func shouldShowProfile(at index: Int, in messages: [Chat]) -> Bool {
        guard index > 0 else { return true }
        let current = messages[index]
        let previous = messages[index - 1]
        return current.sender.id != previous.sender.id
    }

}
