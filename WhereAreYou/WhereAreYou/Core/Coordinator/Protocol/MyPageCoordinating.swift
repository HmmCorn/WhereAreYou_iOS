//
//  MyPageCoordinating.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

import Foundation

/// MyPageViewController가 필요로 하는 화면전환만 선언한 프로토콜
protocol MyPageCoordinating: AnyObject {

    func showProfileEdit(
        nickname: String,
        profileImageName: String,
        onProfileSaved: @escaping (_ nickname: String, _ profileImageName: String) -> Void
    )
    func showLocationSharingSelection(
        selectedOption: LocationSharingOption,
        onOptionSelected: @escaping (LocationSharingOption) -> Void
    )
    func showLocationPermission()
    func showAppointmentNotificationList(
        fetchItems: @escaping () -> [AppointmentListItem],
        onToggle: @escaping (String) -> Void
    )
    func signOut()

}
