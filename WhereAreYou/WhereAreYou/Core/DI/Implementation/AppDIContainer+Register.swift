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
        register(FCMTokenRepository.self, instance: FirestoreFCMTokenRepository())
        register(FCMTokenService.self, instance: FCMTokenService(
            authRepository: resolve(AuthRepository.self),
            fcmTokenRepository: resolve(FCMTokenRepository.self)
        ))

        // 세션 검증
        register(SessionValidationService.self, instance: SessionValidationService(
            authRepository: resolve(AuthRepository.self),
            userRepository: resolve(UserRepository.self)
        ))

        // 프로필 이미지
        register(ProfileImageRepository.self, instance: StorageProfileImageRepository())

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
    }

}
