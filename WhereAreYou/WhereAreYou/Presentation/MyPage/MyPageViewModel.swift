//
//  MyPageViewModel.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/25/26.
//

import CoreLocation

// MARK: - 마이페이지 화면(탭)의 데이터
//       - profile: 프로필 카드에 표시할 사용자 정보
//       - appointmentNotifications: 약속별 알림 화면에서 쓸 약속 목록
//       - locationPermissionState: CLLocationManager의 실제 권한 상태를 그때그때 조회해서 변환
//         (지금은 이 ViewModel이 CLLocationManager와 변환 로직을 함께 들고 있지만,
//          추후 Data 계층(Repository)으로 위치 권한 조회를 옮길 때 이 변환도 함께 옮겨짐을 예상)

final class MyPageViewModel: NSObject {

    private(set) var profile: MyPageProfile
    private(set) var appointmentNotifications: [AppointmentListItem] = []

    var onLocationPermissionChanged: (() -> Void)?

    private let locationManager = CLLocationManager()

    init(profile: MyPageProfile? = nil) {
        self.profile = profile ?? Self.makeDummyProfile()
        super.init()
        locationManager.delegate = self
        loadDummyAppointmentNotifications()
    }

}

// MARK: - 프로필

extension MyPageViewModel {

    func setProfile(nickname: String, profileImageName: String) {
        profile = MyPageProfile(
            nickname: nickname,
            profileImageName: profileImageName,
            locationSharingOption: profile.locationSharingOption,
            isNotificationEnabled: profile.isNotificationEnabled
        )
    }

    func setNotificationEnabled(_ isEnabled: Bool) {
        profile = MyPageProfile(
            nickname: profile.nickname,
            profileImageName: profile.profileImageName,
            locationSharingOption: profile.locationSharingOption,
            isNotificationEnabled: isEnabled
        )
    }

    func setLocationSharingOption(_ option: LocationSharingOption) {
        profile = MyPageProfile(
            nickname: profile.nickname,
            profileImageName: profile.profileImageName,
            locationSharingOption: option,
            isNotificationEnabled: profile.isNotificationEnabled
        )
    }

    private static func makeDummyProfile() -> MyPageProfile {
        MyPageProfile(
            nickname: "성훈",
            profileImageName: "shark",
            locationSharingOption: .onlyDuringAppointment,
            isNotificationEnabled: true
        )
    }

}

// MARK: - 약속별 알림

extension MyPageViewModel {

    func toggleNotification(id: String) {
        guard let index = appointmentNotifications.firstIndex(where: { $0.id == id }) else { return }
        let item = appointmentNotifications[index]
        appointmentNotifications[index] = AppointmentListItem(
            id: item.id,
            title: item.title,
            participantCount: item.participantCount,
            location: item.location,
            date: item.date,
            isNotificationEnabled: !item.isNotificationEnabled
        )
    }

    private func loadDummyAppointmentNotifications() {
        appointmentNotifications = [
            AppointmentListItem(
                id: "1",
                title: "고등학교 친구들과 저녁",
                participantCount: 5,
                location: AppointmentLocation(
                    title: "고기굽는방앗간 이수역점",
                    address: "",
                    coordinate: Coordinate(latitude: 0, longitude: 0)
                ),
                date: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
                isNotificationEnabled: true
            ),
            AppointmentListItem(
                id: "2",
                title: "스터디 모임",
                participantCount: 3,
                location: AppointmentLocation(
                    title: "강남역 스터디카페",
                    address: "",
                    coordinate: Coordinate(latitude: 0, longitude: 0)
                ),
                date: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
                isNotificationEnabled: false
            ),
            AppointmentListItem(
                id: "3",
                title: "가족 모임",
                participantCount: 4,
                location: AppointmentLocation(
                    title: "할머니댁",
                    address: "",
                    coordinate: Coordinate(latitude: 0, longitude: 0)
                ),
                date: Calendar.current.date(byAdding: .day, value: 10, to: Date()),
                isNotificationEnabled: true
            )
        ]
    }

}

// MARK: - 위치 권한

extension MyPageViewModel {

    enum LocationPermissionAction {
        case requested
        case shouldOpenSettings
    }

    var locationPermissionState: LocationPermissionState {
        switch locationManager.authorizationStatus {
        case .notDetermined: return .notDetermined
        case .denied: return .denied
        case .restricted: return .restricted
        case .authorizedAlways: return .authorizedAlways
        case .authorizedWhenInUse: return .authorizedWhenInUse
        @unknown default: return .notDetermined
        }
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func handlePermissionAction() -> LocationPermissionAction {
        if locationPermissionState == .notDetermined {
            requestLocationPermission()
            return .requested
        }
        return .shouldOpenSettings
    }

}

// MARK: - CLLocationManagerDelegate

extension MyPageViewModel: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        onLocationPermissionChanged?()
    }

}
