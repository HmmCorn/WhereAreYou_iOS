//
//  SignInCredential.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-06.
//

import Foundation

/// 로그인 결과에서 추출한 인증 정보
struct SignInCredential {

    let idToken: String
    let nonce: String
    let nickname: String?

}
