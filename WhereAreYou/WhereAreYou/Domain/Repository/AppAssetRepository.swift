//
//  AppAssetRepository.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/21/26.
//

import Foundation

/// 앱 정적 이미지 에셋 저장소 — 원격 에셋 데이터 다운로드
protocol AppAssetRepository {

    /// 캐시(디스크 해시 일치) 또는 원격에서 데이터 조회 후 isValid로 검증
    ///
    /// 검증 성공 데이터만 캐시 확정 저장, 캐시된 데이터의 검증 실패 시 캐시 무효화 — 커밋/무효화 시점은 내부에서 전담
    func loadValidatedImageData(_ asset: AppAsset, isValid: (Data) -> Bool) async throws -> Data

}
