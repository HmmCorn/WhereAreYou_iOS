//
//  NavigationCoordinator.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

import UIKit

/// UINavigationController을 이용해 화면을 전환하는 Coordinator가 채택하는 프로토콜
protocol NavigationCoordinator: Coordinator {

    /// 이 Coordinator가 화면전환에 사용하는 내비게이션 스택
    var navigationController: UINavigationController { get }

}

/// 기본 동작 정의
extension NavigationCoordinator {

    /// 화면을 현재 내비게이션 스택에 push
    func push(_ viewController: UIViewController, animated: Bool = true) {
        navigationController.pushViewController(viewController, animated: animated)
    }

    /// 화면을 모달로 present
    func present(_ viewController: UIViewController, animated: Bool = true) {
        navigationController.present(viewController, animated: animated)
    }

    /// 화면을 별도의 UINavigationController로 감싸 모달로 present
    func presentInNavigationController(
        _ viewController: UIViewController,
        configure: ((UINavigationController) -> Void)? = nil,
        animated: Bool = true
    ) {
        let wrapped = UINavigationController(rootViewController: viewController)
        configure?(wrapped)
        navigationController.present(wrapped, animated: animated)
    }

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

    /// 장소 검색 화면을 모달로 present, 화면 인스턴스를 반환
    func showPlaceSearch(
        screenFactory: ScreenFactory,
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
