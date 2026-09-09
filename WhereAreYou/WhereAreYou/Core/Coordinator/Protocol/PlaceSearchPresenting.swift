//
//  PlaceSearchPresenting.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/8/26.
//

import UIKit

/// 장소 검색 화면을 모달로 present할 수 있는 Coordinator가 채택하는 프로토콜
protocol PlaceSearchPresenting: NavigationCoordinator { }

extension PlaceSearchPresenting {

    /// 장소 검색 화면을 모달로 present, 화면 인스턴스를 반환
    func showPlaceSearch(
        screenFactory: SearchPlaceScreenFactory,
        selectionButtonTitle: String,
        style: SearchPlaceCardViewController.Style
    ) -> SearchPlaceCardViewController {
        let viewController = screenFactory.makeSearchPlaceCardViewController(
            selectionButtonTitle: selectionButtonTitle,
            style: style
        )
        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        present(viewController)
        return viewController
    }

}
