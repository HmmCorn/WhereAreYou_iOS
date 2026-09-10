//
//  DatePickerPresenting.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/8/26.
//

import UIKit

/// 날짜/시간 선택 시트를 모달로 present할 수 있는 Coordinator가 채택하는 프로토콜
protocol DatePickerPresenting: NavigationCoordinator { }

extension DatePickerPresenting {

    /// 날짜/시간 선택 시트를 모달로 present
    func showDatePicker(title: String, initialDate: Date?, onDateSelected: @escaping (Date) -> Void) {
        let viewController = DatePickerSheetViewController(title: title, initialDate: initialDate)
        viewController.onDateSelected = onDateSelected

        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        present(viewController)
    }

}
