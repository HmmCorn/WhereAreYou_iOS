//
//  ChatRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-30.
//

import Foundation

/// 채팅 메시지 저장소 — 조회, 전송
protocol ChatRepository {
    func fetchMessages(appointmentID: String, completion: @escaping (Result<[Chat], Error>) -> Void)
    func sendChat(appointmentID: String, contentType: ChatContentType, completion: @escaping (Result<Chat, Error>) -> Void)
}
