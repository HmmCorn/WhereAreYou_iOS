//
//  ChatDisplayItem.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-03.
//

import Foundation

/// 채팅 기본 정보 + 발신자 + 프로필 이미지 표시 여부
enum ChatDisplayItem {
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
}
