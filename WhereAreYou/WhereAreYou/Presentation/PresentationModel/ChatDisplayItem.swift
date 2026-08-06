//
//  ChatDisplayItem.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-03.
//

import Foundation

/// 채팅 기본 정보 + 발신자 + 프로필 이미지 표시 여부
enum ChatDisplayItem: Sendable {
    case myMessage(ChatBubbleItem)
    case otherMessage(ChatBubbleItem, showProfile: Bool)

    var senderID: String {
        switch self {
        case .myMessage(let b): b.senderID
        case .otherMessage(let b, _): b.senderID
        }
    }

    var sentAt: Date {
        switch self {
        case .myMessage(let b): b.sentAt
        case .otherMessage(let b, _): b.sentAt
        }
    }

    var isMe: Bool {
        if case .myMessage = self { return true }
        return false
    }

    var id: String {
        switch self {
        case .myMessage(let b): b.id
        case .otherMessage(let b, _): b.id
        }
    }
}

nonisolated extension ChatDisplayItem: Hashable {
    static func == (lhs: ChatDisplayItem, rhs: ChatDisplayItem) -> Bool {
        switch (lhs, rhs) {
        case (.myMessage(let a), .myMessage(let b)):
            return a == b
        case (.otherMessage(let a, let showA), .otherMessage(let b, let showB)):
            return a == b && showA == showB
        default:
            return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .myMessage(let b):
            hasher.combine(0)
            hasher.combine(b)
        case .otherMessage(let b, let showProfile):
            hasher.combine(1)
            hasher.combine(b)
            hasher.combine(showProfile)
        }
    }
}
