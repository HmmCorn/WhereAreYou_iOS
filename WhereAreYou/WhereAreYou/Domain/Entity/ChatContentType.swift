//
//  ChatContentType.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-03.
//

enum ChatContentType {
    case text
    case locationShare(Coordinate)
    case placeShare(Place)
}
