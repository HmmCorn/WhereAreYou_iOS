//
//  UIImageView+ProfileImage.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-13.
//

import UIKit
import ObjectiveC

/// UIImageView에서 프로필 아바타 식별자로 Storage 이미지를 비동기 로딩하는 extension
extension UIImageView {

    func setProfileImage(_ identifier: String) {
        currentProfileIdentifier = identifier
        image = nil
        hideLoadingIndicator()

        let showTask = Task { [weak self] in
            try await Task.sleep(for: .milliseconds(150))
            self?.showLoadingIndicator()
        }

        Task { [weak self] in
            let loaded = await ProfileImageLoader.shared.load(identifier: identifier)
            showTask.cancel()
            guard self?.currentProfileIdentifier == identifier else { return }
            self?.hideLoadingIndicator()
            self?.image = loaded
        }
    }

}

private var profileIdentifierKey: UInt8 = 0

private extension UIImageView {

    var currentProfileIdentifier: String? {
        get { objc_getAssociatedObject(self, &profileIdentifierKey) as? String }
        set { objc_setAssociatedObject(self, &profileIdentifierKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

}
