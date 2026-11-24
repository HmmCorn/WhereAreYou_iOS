//
//  UIAlertController+SearchTimeNotice.swift
//  WhereAreYou
//
//  Created by 김성훈 on 11/24/26.
//

import UIKit

// MARK: - 대중교통 검색 시각 안내 알럿
//       - 검색 시각과 출발 시각이 차이 나는 대중교통 경로 선택 시 표시

extension UIAlertController {

    static func searchTimeNoticeAlert(
        searchedAt: Date,
        departureTime: Date,
        onConfirm: @escaping () -> Void
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: "현재 시각 기준 경로예요",
            message: """
            이 경로는 현재 시각(\(searchedAt.koreanTimeString)) 기준으로 검색했어요. \
            출발 시각(\(departureTime.koreanTimeString))에는 대중교통 운행이 달라 경로가 다를 수 있으니 \
            출발 시각에 다시 검색해 보세요.
            """,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "이 경로 선택", style: .default) { _ in onConfirm() })
        return alert
    }

}
