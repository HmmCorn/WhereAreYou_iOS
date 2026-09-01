//
//  ChatBubbleItem.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-03.
//

import Foundation

/// 채팅 기본 정보
struct ChatBubbleItem: Sendable {
    let id: String
    let senderID: String
    let senderNickname: String
    let senderProfileImage: String
    let content: String
    let timeText: String?
    let sentAt: Date
    let contentType: BubbleContentType

    /// `nonisolated extension ChatBubbleItem: Hashable`의 `==`에서 비교되므로
    /// 합성 Equatable 준수도 nonisolated여야 한다.
    nonisolated enum BubbleContentType: Sendable {
        case text
        case locationShare(coordinate: Coordinate)
        case placeShare(placeName: String, placeAddress: String, coordinate: Coordinate, isDuplicate: Bool)
    }
}

nonisolated extension ChatBubbleItem.BubbleContentType: Equatable {
    static func == (lhs: ChatBubbleItem.BubbleContentType, rhs: ChatBubbleItem.BubbleContentType) -> Bool {
        switch (lhs, rhs) {
        case (.text, .text):
            return true
        case (.locationShare, .locationShare):
            return true
        case (.placeShare(let lName, let lAddress, _, let lDuplicate), .placeShare(let rName, let rAddress, _, let rDuplicate)):
            return lName == rName && lAddress == rAddress && lDuplicate == rDuplicate
        default:
            return false
        }
    }
}

nonisolated extension ChatBubbleItem: Hashable {
    static func == (lhs: ChatBubbleItem, rhs: ChatBubbleItem) -> Bool {
        lhs.id == rhs.id
            && lhs.timeText == rhs.timeText
            && lhs.content == rhs.content
            && lhs.contentType == rhs.contentType
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(timeText)
    }
}
