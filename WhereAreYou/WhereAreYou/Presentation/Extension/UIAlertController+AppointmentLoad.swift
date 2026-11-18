//
//  UIAlertController+AppointmentLoad.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-11-07.
//

import UIKit

/// 약속 목록 조회 실패 알럿 — 홈·약속 목록·지난 약속 화면에서 같은 문구로 재사용
extension UIAlertController {

    static func appointmentLoadFailureAlert() -> UIAlertController {
        let alert = UIAlertController(
            title: "약속을 불러오지 못했어요",
            message: "잠시 후 다시 시도해 주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        return alert
    }

}
