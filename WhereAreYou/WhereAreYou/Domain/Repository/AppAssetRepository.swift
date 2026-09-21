//
//  AppAssetRepository.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/21/26.
//

import Foundation

/// 앱 정적 이미지 에셋 저장소 — 원격 에셋 데이터 다운로드
protocol AppAssetRepository {

    /// 캐시(디스크 해시 일치) 또는 원격에서 데이터 로드
    func loadImageData(_ asset: AppAsset) async throws -> AppAssetData

    /// 메모리/디스크 캐시에 저장
    func commitCache(_ asset: AppAsset, data: AppAssetData)

    /// 메모리/디스크 캐시 무효화
    func invalidateCache(_ asset: AppAsset)

}
