//
//  AppAsset.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/21/26.
//

import Foundation

/// Firebase Storage에서 받아오는 앱 정적 이미지 에셋
enum AppAsset: CaseIterable, Hashable {

    case pin
    case logo
    case loginBackground

    /// Firebase Storage 상의 경로
    var storagePath: String {
        "app-assets/\(fileName).png"
    }

    /// 디스크 캐시에 저장할 파일명
    var cacheFileName: String {
        "\(fileName).png"
    }

    /// 원격 해시(md5Hash)를 저장할 UserDefaults 키
    var cachedHashKey: String {
        "AppAsset.hash.\(fileName)"
    }

    private var fileName: String {
        switch self {
        case .pin:
            return "pin"
        case .logo:
            return "logo"
        case .loginBackground:
            return "loginBackground"
        }
    }

}
