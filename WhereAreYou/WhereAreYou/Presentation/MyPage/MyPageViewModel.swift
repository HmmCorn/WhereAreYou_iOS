//
//  MyPageViewModel.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/25/26.
//

import Combine
import Foundation

// MARK: - 마이페이지 화면(탭)의 데이터
//       - profile: 프로필 카드·위치 공유·전체 알림에 표시할 내 유저 정보
//         (수정은 화면에 먼저 반영하고, 저장에 실패하면 이전 값으로 되돌린 뒤 profileSaveFailure를 발행)
//       - appointmentNotifications: 약속별 알림 화면에서 쓸 약속 목록
//       - locationPermissionState: 위치 권한 상태를 표시용 타입으로 변환해 발행
//         (실제 CoreLocation 접근은 Data 계층이 담당하며, ObserveLocationPermissionUseCase를 통해 전달받음)
//       - liveActivityPermissionState: 실시간 현황 허용 상태를 표시용 타입으로 변환해 발행
//         (ActivityKit 접근은 Data 계층이 담당하며, ObserveLiveActivityPermissionUseCase를 통해 전달받음)

final class MyPageViewModel {

    @Published private(set) var profile: MyPageProfile?
    @Published private(set) var profileSaveFailure: ProfileSaveFailure?

    @Published private(set) var appointmentNotifications: [AppointmentListItem] = []
    @Published private(set) var locationPermissionState: LocationPermissionState
    @Published private(set) var liveActivityPermissionState: LiveActivityPermissionState
    @Published private(set) var signOutResult: Result<Void, Error>?

    private let fetchMyUserUseCase: FetchMyUserUseCase
    private let updateMyUserUseCase: UpdateMyUserUseCase
    private let fetchMyAppointmentsUseCase: FetchMyAppointmentsUseCase
    private let observeLocationPermissionUseCase: ObserveLocationPermissionUseCase
    private let observeLiveActivityPermissionUseCase: ObserveLiveActivityPermissionUseCase
    private let signOutUseCase: SignOutUseCase

    /// 저장 요청마다 올라가는 번호 — 늦게 도착한 이전 요청의 결과가 최신 값을 덮어쓰지 않게 한다
    private var latestProfileSaveID = 0

    init(
        fetchMyUserUseCase: FetchMyUserUseCase,
        updateMyUserUseCase: UpdateMyUserUseCase,
        fetchMyAppointmentsUseCase: FetchMyAppointmentsUseCase,
        observeLocationPermissionUseCase: ObserveLocationPermissionUseCase,
        observeLiveActivityPermissionUseCase: ObserveLiveActivityPermissionUseCase,
        signOutUseCase: SignOutUseCase
    ) {
        self.fetchMyUserUseCase = fetchMyUserUseCase
        self.updateMyUserUseCase = updateMyUserUseCase
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

    /// 실패해도 알럿 없이 이전 값을 유지한다
    func loadProfile() {
        Task { @MainActor in
            guard let user = try? await fetchMyUserUseCase.execute() else { return }
            profile = MyPageProfile(user: user)
        }
    }

    func saveProfile(nickname: String, profileImageName: String) {
        guard let current = profile,
              nickname != current.nickname || profileImageName != current.profileImageName
        else { return }

        save(
            MyPageProfile(
                nickname: nickname,
                profileImageName: profileImageName,
                locationSharingOption: current.locationSharingOption,
                isNotificationEnabled: current.isNotificationEnabled
            ),
            item: .profile,
            retry: { [weak self] in self?.saveProfile(nickname: nickname, profileImageName: profileImageName) }
        ) {
            try await self.updateMyUserUseCase.execute(nickname: nickname, profileImage: profileImageName)
        }
    }

    func saveNotificationEnabled(_ isEnabled: Bool) {
        guard let current = profile, isEnabled != current.isNotificationEnabled else { return }

        save(
            MyPageProfile(
                nickname: current.nickname,
                profileImageName: current.profileImageName,
                locationSharingOption: current.locationSharingOption,
                isNotificationEnabled: isEnabled
            ),
            item: .notification,
            retry: { [weak self] in self?.saveNotificationEnabled(isEnabled) }
        ) {
            try await self.updateMyUserUseCase.execute(isNotificationEnabled: isEnabled)
        }
    }

    func saveLocationSharingOption(_ option: LocationSharingOption) {
        guard let current = profile, option != current.locationSharingOption else { return }

        save(
            MyPageProfile(
                nickname: current.nickname,
                profileImageName: current.profileImageName,
                locationSharingOption: option,
                isNotificationEnabled: current.isNotificationEnabled
            ),
            item: .locationSharing,
            retry: { [weak self] in self?.saveLocationSharingOption(option) }
        ) {
            try await self.updateMyUserUseCase.execute(locationSharingScope: option.scope)
        }
    }

    /// 바뀐 값을 먼저 화면에 반영하고 저장한다. 성공하면 저장된 값으로, 실패하면 이전 값으로 맞춘다
    private func save(
        _ newProfile: MyPageProfile,
        item: ProfileSaveFailure.Item,
        retry: @escaping () -> Void,
        update: @escaping () async throws -> User
    ) {
        guard let previous = profile else { return }

        latestProfileSaveID += 1
        let saveID = latestProfileSaveID
        profile = newProfile

        Task { @MainActor in
            do {
                let user = try await update()
                guard saveID == latestProfileSaveID else { return }
                profile = MyPageProfile(user: user)
            } catch {
                guard saveID == latestProfileSaveID else { return }
                profile = previous
                let isNetworkError: Bool
                if case AppError.network = error {
                    isNetworkError = true
                } else {
                    isNetworkError = false
                }
                profileSaveFailure = ProfileSaveFailure(item: item, isNetworkError: isNetworkError, retry: retry)
            }
        }
    }

}

// MARK: - 저장 실패

/// 저장에 실패한 항목과 원인, 같은 값으로 다시 저장하는 동작 — 화면이 알럿 문구와 다시 시도 버튼을 만드는 데 쓴다
struct ProfileSaveFailure {

    enum Item {
        case profile
        case locationSharing
        case notification
    }

    let item: Item
    let isNetworkError: Bool
    let retry: () -> Void

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
