//
//  AppAssetRepository.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/21/26.
//

import Foundation

/// 앱 정적 이미지 에셋 저장소 — 원격 에셋 데이터 다운로드
protocol AppAssetRepository {

    func downloadImageData(_ asset: AppAsset) async throws -> Data

    /// 메모리/디스크 캐시 무효화
    func invalidateCache(_ asset: AppAsset)

}
