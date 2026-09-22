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
    func load(_ asset: AppAsset) async -> UIImage? {
        guard let data = try? await repository.loadValidatedImageData(asset, isValid: { UIImage(data: $0) != nil }) else {
            return nil
        }
        return UIImage(data: data)
    }

}
