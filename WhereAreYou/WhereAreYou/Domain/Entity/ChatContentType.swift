//
//  ChatContentType.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-03.
//

/// 채팅 메시지 유형 — 텍스트, 위치 공유, 장소 공유
enum ChatContentType {
    case text
    case locationShare(Coordinate)
    case placeShare(Place)
}
