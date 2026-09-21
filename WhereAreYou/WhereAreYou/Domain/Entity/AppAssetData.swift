//
//  AppAssetData.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/22/26.
//

import Foundation

/// AppAssetRepository가 반환하는 원본 데이터와 캐시 커밋에 필요한 정보
struct AppAssetData {

    let data: Data

    /// 원격에서 조회한 해시 — 캐시 커밋 시 저장할 값
    let remoteHash: String?

    /// 이미 검증되어 디스크에 저장된 상태인지 여부 — true면 commitCache 호출이 불필요
    let isAlreadyCached: Bool

}
