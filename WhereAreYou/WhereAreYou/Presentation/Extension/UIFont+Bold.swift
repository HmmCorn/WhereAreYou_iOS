//
//  UIFont+Bold.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/19/26.
//

import UIKit

// MARK: - 특정 텍스트 스타일에 Bold 트레잇만 추가한 폰트를 만든다
//       - Dynamic Type 스케일링은 원본 textStyle을 그대로 따른다

extension UIFont {
    static func boldPreferredFont(forTextStyle textStyle: UIFont.TextStyle) -> UIFont {
        let baseDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
        guard let boldDescriptor = baseDescriptor.withSymbolicTraits(.traitBold) else {
            return .preferredFont(forTextStyle: textStyle)
        }
        return UIFont(descriptor: boldDescriptor, size: 0)
    }
}
