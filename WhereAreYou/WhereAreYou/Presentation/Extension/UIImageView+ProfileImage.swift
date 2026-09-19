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
        profileLoadTask?.cancel()
        indicatorDelayTask?.cancel()
        currentProfileIdentifier = identifier
        image = nil
        hideLoadingIndicator()

        indicatorDelayTask = Task { [weak self] in
            try await Task.sleep(for: .milliseconds(150))
            self?.showLoadingIndicator()
        }

        let showTask = indicatorDelayTask
        profileLoadTask = Task { [weak self] in
            let loaded = await ProfileImageLoader.shared.load(identifier: identifier)
            showTask?.cancel()
            guard !Task.isCancelled else { return }
            guard self?.currentProfileIdentifier == identifier else { return }
            self?.hideLoadingIndicator()
            self?.image = loaded
        }
    }

}

private var profileIdentifierKey: UInt8 = 0
private var profileLoadTaskKey: UInt8 = 0
private var indicatorDelayTaskKey: UInt8 = 0

private extension UIImageView {

    var currentProfileIdentifier: String? {
        get { objc_getAssociatedObject(self, &profileIdentifierKey) as? String }
        set { objc_setAssociatedObject(self, &profileIdentifierKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var profileLoadTask: Task<Void, Never>? {
        get { objc_getAssociatedObject(self, &profileLoadTaskKey) as? Task<Void, Never> }
        set { objc_setAssociatedObject(self, &profileLoadTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var indicatorDelayTask: Task<Void, Error>? {
        get { objc_getAssociatedObject(self, &indicatorDelayTaskKey) as? Task<Void, Error> }
        set { objc_setAssociatedObject(self, &indicatorDelayTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

}
