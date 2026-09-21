//
//  UIImageView+AppAsset.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/22/26.
//

import UIKit
import ObjectiveC

/// UIImageView에서 앱 정적 에셋을 비동기로 로딩하는 extension
extension UIImageView {

    /// - Parameters:
    ///   - asset: 로딩할 앱 정적 에셋
    ///   - renderingMode: 로딩 완료 후 적용할 렌더링 모드. `tintColor` 사용 시 `.alwaysTemplate` 전달
    func setAppAsset(_ asset: AppAsset, renderingMode: UIImage.RenderingMode = .automatic) {
        appAssetLoadTask?.cancel()
        currentAppAsset = asset

        appAssetLoadTask = Task { [weak self] in
            let loaded = await AppAssetImageLoader.shared.load(asset)
            guard !Task.isCancelled else { return }
            guard let self, self.currentAppAsset == asset else { return }

            self.image = loaded?.withRenderingMode(renderingMode)
            guard loaded != nil else { return }

            self.alpha = 0
            UIView.animate(withDuration: 0.2) {
                self.alpha = 1
            }
        }
    }

}

private var currentAppAssetKey: UInt8 = 0
private var appAssetLoadTaskKey: UInt8 = 0

private extension UIImageView {

    var currentAppAsset: AppAsset? {
        get { objc_getAssociatedObject(self, &currentAppAssetKey) as? AppAsset }
        set { objc_setAssociatedObject(self, &currentAppAssetKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var appAssetLoadTask: Task<Void, Never>? {
        get { objc_getAssociatedObject(self, &appAssetLoadTaskKey) as? Task<Void, Never> }
        set { objc_setAssociatedObject(self, &appAssetLoadTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

}
