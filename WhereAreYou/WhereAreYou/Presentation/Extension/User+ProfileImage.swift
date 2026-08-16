//
//  User+ProfileImage.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-17.
//

import Foundation

extension User {

    /// 프로필 이미지 URL에서 화면에 사용할 에셋 이름만 추출
    /// - 서버 연동 후 이미지 표현이 바뀌면 이 프로퍼티 한 곳만 수정하면 된다.
    var profileImageName: String {
        profileImage.lastPathComponent
    }

}
