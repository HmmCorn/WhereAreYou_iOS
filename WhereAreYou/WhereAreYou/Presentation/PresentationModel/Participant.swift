//
//  Participant.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-14.
//

struct Participant {

    let id: String
    let nickname: String
    let profileImage: String

    init(user: User) {
        id = user.id
        nickname = user.nickname
        self.profileImage = user.profileImage
    }

    init(id: String, nickname: String, profileImage: String) {
        self.id = id
        self.nickname = nickname
        self.profileImage = profileImage
    }

}
