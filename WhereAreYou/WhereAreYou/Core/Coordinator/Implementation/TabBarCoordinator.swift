//
//  TabBarCoordinator.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

import UIKit

/// Home / AppointmentList / MyPage 3개 탭의
/// UINavigationController와 각 탭 Coordinator를 생성하고 소유
final class TabBarCoordinator: Coordinator {

    let tabBarController = UITabBarController()
    var onSignOut: (() -> Void)?

    private var homeCoordinator: HomeCoordinator?
    private var appointmentListCoordinator: AppointmentListCoordinator?
    private var myPageCoordinator: MyPageCoordinator?

    func start() {
        let homeNav = UINavigationController()
        homeCoordinator = HomeCoordinator(navigationController: homeNav)
        homeCoordinator?.start()
        homeNav.tabBarItem = UITabBarItem(
            title: "홈",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        let listNav = UINavigationController()
        appointmentListCoordinator = AppointmentListCoordinator(navigationController: listNav)
        appointmentListCoordinator?.start()
        listNav.tabBarItem = UITabBarItem(
            title: "약속",
            image: UIImage(systemName: "tray.full"),
            selectedImage: UIImage(systemName: "tray.full.fill")
        )

        let myPageNav = UINavigationController()
        let myPageCoord = MyPageCoordinator(navigationController: myPageNav)
        myPageCoord.onSignOut = { [weak self] in
            self?.onSignOut?()
        }
        myPageCoordinator = myPageCoord
        myPageCoord.start()
        myPageNav.tabBarItem = UITabBarItem(
            title: "마이페이지",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )

        tabBarController.viewControllers = [homeNav, listNav, myPageNav]
        tabBarController.tabBar.tintColor = .blue1
    }

    // MARK: - 딥링크

    /// 지금 탭의 코디네이터가 자기 화면에서 처리할 수 있으면 맡기고,
    /// 아니면 떠 있는 모달을 정리한 뒤 약속 탭에서 목적지를 새로 띄운다
    func handle(deepLink: AppointmentDeepLink) {
        if selectedTabCoordinator?.handleInPlace(deepLink) == true { return }

        guard let appointmentListCoordinator else { return }
        let showInAppointmentList = { [weak self] in
            guard let self else { return }
            self.tabBarController.selectedViewController = appointmentListCoordinator.navigationController
            appointmentListCoordinator.showFromDeepLink(deepLink)
        }

        // 모든 탭의 모달은 루트인 탭바 컨트롤러 위에 뜨므로 여기서 한 번에 정리한다
        guard tabBarController.presentedViewController != nil else {
            showInAppointmentList()
            return
        }
        tabBarController.dismiss(animated: false, completion: showInAppointmentList)
    }

    private var selectedTabCoordinator: AppointmentDeepLinkHandling? {
        let selectedViewController = tabBarController.selectedViewController
        if selectedViewController === homeCoordinator?.navigationController { return homeCoordinator }
        if selectedViewController === appointmentListCoordinator?.navigationController { return appointmentListCoordinator }
        return nil
    }

}
