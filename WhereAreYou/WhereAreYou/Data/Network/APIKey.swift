//
//  APIKey.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/29/26.
//

import Foundation

/// Info.plist에 등록된 외부 API 키를 한 곳에서 읽어오기 위한 타입
enum APIKey {

    /// 카카오 로컬 API 호출에 사용하는 REST API 키
    static var kakaoRestAPIKey: String {
        value(forInfoDictionaryKey: "KakaoRestAPIKey")
    }

    // MARK: - Private

    /// Info.plist에서 키 값을 조회
    /// Config.xcconfig에 키가 설정되지 않았을 때 assertionFailure로 알림
    private static func value(forInfoDictionaryKey key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
              !value.isEmpty,
              !value.hasPrefix("$(") else {
            assertionFailure("Info.plist에 \(key) 값이 설정되어 있지 않습니다. Config.xcconfig를 확인하세요.")
            return ""
        }
        return value
    }
}
