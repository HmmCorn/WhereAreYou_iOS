//
//  AppAssetImageLoader.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/22/26.
//

import UIKit

/// 앱 정적 에셋을 로드해 UIImage로 변환하는 싱글턴 로더
final class AppAssetImageLoader {

    static let shared = AppAssetImageLoader()

    private let repository: AppAssetRepository

    private init() {
        repository = DIContainer.shared.resolve(AppAssetRepository.self)
    }

    /// 실패 시 nil 반환 — 정적 UI 요소이므로 별도 실패 이미지 없이 빈 상태 유지
    ///
    /// UIImage 변환 실패(캐시된 데이터 손상 등) 시 캐시 무효화 후 1회 재시도
    func load(_ asset: AppAsset) async -> UIImage? {
        guard let data = try? await repository.downloadImageData(asset) else {
            return nil
        }

        if let image = UIImage(data: data) {
            return image
        }

        repository.invalidateCache(asset)
        guard let retriedData = try? await repository.downloadImageData(asset) else {
            return nil
        }
        return UIImage(data: retriedData)
    }

}
