//
//  Chat.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-30.
//

import Foundation

/// 약속 채팅 메시지
struct Chat {
    let id: String
    let appointmentID: String
    let sender: User
    let text: String
    let sentAt: Date
    let contentType: ChatContentType
}
