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
        myPageCoordinator = MyPageCoordinator(navigationController: myPageNav)
        myPageCoordinator?.start()
        myPageNav.tabBarItem = UITabBarItem(
            title: "마이페이지",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )

        tabBarController.viewControllers = [homeNav, listNav, myPageNav]
        tabBarController.tabBar.tintColor = .blue1
    }

}
