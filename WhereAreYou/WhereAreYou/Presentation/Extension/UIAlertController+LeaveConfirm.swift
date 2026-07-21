//
//  UIAlertController+LeaveConfirm.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/21/26.
//

import UIKit

// MARK: - 약속 나가기(목록에서 제거) 확인 알럿
//       - 약속 목록/지난 약속 화면에서 동일한 문구·동작으로 재사용

extension UIAlertController {

    static func leaveConfirmAlert(title: String, onConfirm: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(
            title: "약속 나가기",
            message: "'\(title)' 약속에서 나가시겠어요?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "나가기", style: .destructive) { _ in onConfirm() })
        return alert
    }

}
