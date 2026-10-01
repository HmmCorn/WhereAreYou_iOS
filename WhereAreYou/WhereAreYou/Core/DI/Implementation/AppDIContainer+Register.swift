//
//  AppDIContainer+Register.swift
//  WhereAreYou
//
//  Created by 김성훈 on 8/26/26.
//

import UIKit

extension DIContainer {

    func registerDependencies() {
        // 인증
        register(AuthRepository.self, instance: FirebaseAuthRepository())
        register(UserRepository.self, instance: FirestoreUserRepository())
        register(SignInService.self, instance: AppleSignInProvider(
            windowProvider: {
                UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap { $0.windows }
                    .first { $0.isKeyWindow }
            }
        ))

        // 푸시 알림
        register(FCMInstallationIDRepository.self, instance: FirestoreFCMInstallationIDRepository())
        register(FCMInstallationIDService.self, instance: DefaultFCMInstallationIDService(
            authRepository: resolve(AuthRepository.self),
            fcmInstallationIDRepository: resolve(FCMInstallationIDRepository.self)
        ))

        // 세션 검증
        register(SessionValidationService.self, instance: DefaultSessionValidationService(
            authRepository: resolve(AuthRepository.self),
            userRepository: resolve(UserRepository.self)
        ))

        // 프로필 이미지
        register(ProfileImageRepository.self, instance: StorageProfileImageRepository())

        // 앱 정적 에셋
        register(AppAssetRepository.self, instance: StorageAppAssetRepository())

        // 위치
        let coreLocationRepository = CoreLocationRepository()
        register(LocationRepository.self, instance: coreLocationRepository)
        register(LocationPermissionRepository.self, instance: coreLocationRepository)

        // 약속 생성/조회
        register(AppointmentCreationRepository.self) { MockAppointmentCreationRepository() }
        register(AppointmentDetailRepository.self) { MockAppointmentDetailRepository() }
        register(AppointmentInfoRepository.self) { MockAppointmentInfoRepository() }

        // 채팅
        register(ChatRepository.self) { MockChatRepository() }

        // 장소 검색/조회
        register(NearbyPlaceRepository.self) { MockNearbyPlaceRepository() }
        register(PlaceSearchRepository.self) { MockPlaceSearchRepository() }
        register(ReverseGeocodingRepository.self) { MockReverseGeocodingRepository() }
        register(SharedPlaceRepository.self) { MockSharedPlaceRepository() }

        // 길찾기
        register(RouteSearchRepository.self) { MockRouteSearchRepository() }

        // 약속 이동 라이브 액티비티
        register(RouteLiveActivityRepository.self, instance: ActivityKitRouteLiveActivityRepository())
        register(LiveActivityPermissionRepository.self, instance: ActivityKitLiveActivityPermissionRepository())
        // 단계 버튼(LiveActivityIntent)은 AppDelegate가 AppDependencyManager에 넘긴 이 인스턴스를 쓴다
        register(RouteProgressService.self, instance: DefaultRouteProgressService(
            liveActivityRepository: resolve(RouteLiveActivityRepository.self)
        ))
    }

}
