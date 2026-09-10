//
//  MyPageViewModel.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/25/26.
//

import Combine
import Foundation

// MARK: - 마이페이지 화면(탭)의 데이터
//       - profile: 프로필 카드에 표시할 사용자 정보
//       - appointmentNotifications: 약속별 알림 화면에서 쓸 약속 목록
//       - locationPermissionState: 위치 권한 상태를 표시용 타입으로 변환해 발행
//         (실제 CoreLocation 접근은 Data 계층이 담당하며, ObserveLocationPermissionUseCase를 통해 전달받음)

final class MyPageViewModel {

    private(set) var profile: MyPageProfile
    private(set) var appointmentNotifications: [AppointmentListItem] = []

    @Published private(set) var locationPermissionState: LocationPermissionState
    @Published private(set) var signOutResult: Result<Void, Error>?

    private let observeLocationPermissionUseCase: ObserveLocationPermissionUseCase
    private let signOutUseCase: SignOutUseCase
    private var cancellables = Set<AnyCancellable>()

    init(
        profile: MyPageProfile? = nil,
        observeLocationPermissionUseCase: ObserveLocationPermissionUseCase,
        signOutUseCase: SignOutUseCase
    ) {
        self.profile = profile ?? Self.makeDummyProfile()
        self.observeLocationPermissionUseCase = observeLocationPermissionUseCase
        self.signOutUseCase = signOutUseCase
        self.locationPermissionState = LocationPermissionState(observeLocationPermissionUseCase.currentStatus)

        loadDummyAppointmentNotifications()
        bindLocationPermission()
    }

    func signOut() {
        do {
            try signOutUseCase.execute()
            signOutResult = .success(())
        } catch {
            signOutResult = .failure(error)
        }
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

    func requestLocationPermission() {
        observeLocationPermissionUseCase.requestAuthorization()
    }

    func handlePermissionAction() -> LocationPermissionAction {
        if locationPermissionState == .notDetermined {
            requestLocationPermission()
            return .requested
        }
        return .shouldOpenSettings
    }

    private func bindLocationPermission() {
        observeLocationPermissionUseCase.statusPublisher
            .map(LocationPermissionState.init)
            .assign(to: &$locationPermissionState)
    }

}
