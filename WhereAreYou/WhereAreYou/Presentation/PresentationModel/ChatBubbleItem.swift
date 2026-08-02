//
//  ChatBubbleItem.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-03.
//

import Foundation

/// 채팅 기본 정보
struct ChatBubbleItem {
    let id: String
    let senderID: String
    let senderNickname: String
    let senderProfileImage: String
    let content: String
    let timeText: String?
    let sentAt: Date
    let contentType: BubbleContentType

    enum BubbleContentType {
        case text
        case locationShare
        case placeShare(placeName: String, placeAddress: String)
    }
}
