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
//       - liveActivityPermissionState: 실시간 현황 허용 상태를 표시용 타입으로 변환해 발행
//         (ActivityKit 접근은 Data 계층이 담당하며, ObserveLiveActivityPermissionUseCase를 통해 전달받음)

final class MyPageViewModel {

    private(set) var profile: MyPageProfile

    @Published private(set) var appointmentNotifications: [AppointmentListItem] = []
    @Published private(set) var locationPermissionState: LocationPermissionState
    @Published private(set) var liveActivityPermissionState: LiveActivityPermissionState
    @Published private(set) var signOutResult: Result<Void, Error>?

    private let fetchMyAppointmentsUseCase: FetchMyAppointmentsUseCase
    private let observeLocationPermissionUseCase: ObserveLocationPermissionUseCase
    private let observeLiveActivityPermissionUseCase: ObserveLiveActivityPermissionUseCase
    private let signOutUseCase: SignOutUseCase

    init(
        profile: MyPageProfile? = nil,
        fetchMyAppointmentsUseCase: FetchMyAppointmentsUseCase,
        observeLocationPermissionUseCase: ObserveLocationPermissionUseCase,
        observeLiveActivityPermissionUseCase: ObserveLiveActivityPermissionUseCase,
        signOutUseCase: SignOutUseCase
    ) {
        self.profile = profile ?? Self.makeDummyProfile()
        self.fetchMyAppointmentsUseCase = fetchMyAppointmentsUseCase
        self.observeLocationPermissionUseCase = observeLocationPermissionUseCase
        self.observeLiveActivityPermissionUseCase = observeLiveActivityPermissionUseCase
        self.signOutUseCase = signOutUseCase
        self.locationPermissionState = LocationPermissionState(observeLocationPermissionUseCase.currentStatus)
        self.liveActivityPermissionState = LiveActivityPermissionState(observeLiveActivityPermissionUseCase.currentStatus)

        bindLocationPermission()
        bindLiveActivityPermission()
    }

    func signOut() {
        Task { @MainActor in
            do {
                try await signOutUseCase.execute()
                signOutResult = .success(())
            } catch {
                signOutResult = .failure(error)
            }
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

    /// 알림 행의 개수 표시에만 쓰여 실패해도 알럿 없이 이전 목록을 유지한다
    func loadAppointmentNotifications() {
        Task { @MainActor in
            guard let appointments = try? await fetchMyAppointmentsUseCase.execute(from: Date(), to: nil) else {
                return
            }
            // TODO: 약속 알림 연동 시 users.appointmentsNotification 값으로 교체
            appointmentNotifications = appointments.map { appointment in
                AppointmentListItem(
                    appointment: appointment,
                    isNotificationEnabled: appointmentNotifications.first { $0.id == appointment.id }?.isNotificationEnabled ?? true
                )
            }
        }
    }

}

// MARK: - 위치 권한

extension MyPageViewModel {

    private func bindLocationPermission() {
        observeLocationPermissionUseCase.statusPublisher
            .map(LocationPermissionState.init)
            .assign(to: &$locationPermissionState)
    }

}

// MARK: - 실시간 현황 권한

extension MyPageViewModel {

    private func bindLiveActivityPermission() {
        observeLiveActivityPermissionUseCase.statusPublisher
            .map(LiveActivityPermissionState.init)
            .assign(to: &$liveActivityPermissionState)
    }

}
