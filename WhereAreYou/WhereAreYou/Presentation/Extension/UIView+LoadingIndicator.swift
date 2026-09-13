//
//  UIView+LoadingIndicator.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-14.
//

import UIKit
import ObjectiveC

/// UIView에 로딩 인디케이터를 표시·제거하는 extension
extension UIView {

    func showLoadingIndicator(style: UIActivityIndicatorView.Style = .medium, color: UIColor? = nil) {
        guard loadingIndicator == nil else { return }

        let indicator = UIActivityIndicatorView(style: style)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        if let color { indicator.color = color }
        addSubview(indicator)

        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        indicator.startAnimating()
        loadingIndicator = indicator
    }

    func hideLoadingIndicator() {
        loadingIndicator?.stopAnimating()
        loadingIndicator?.removeFromSuperview()
        loadingIndicator = nil
    }

}

private var loadingIndicatorKey: UInt8 = 0

private extension UIView {

    var loadingIndicator: UIActivityIndicatorView? {
        get { objc_getAssociatedObject(self, &loadingIndicatorKey) as? UIActivityIndicatorView }
        set { objc_setAssociatedObject(self, &loadingIndicatorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

}
