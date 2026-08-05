//
//  AppointmentRouteViewModel.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/31/26.
//

import Foundation
import Combine

final class AppointmentRouteViewModel {

    /// 약속 장소명 (지도 핀 캡션, info 영역 목적지명에 사용)
    @Published private(set) var placeName: String?
    /// 약속 장소 좌표 (지도 핀 위치, 초기 카메라 이동 기준점)
    @Published private(set) var placeCoordinate: Coordinate?
    /// 나를 포함한 전체 참여자의 화면 표시용 정보 (지도 마커/폴리라인, info 참여자 리스트에 공통 사용)
    @Published private(set) var participants: [AppointmentRouteParticipant] = []
    /// 나의 경로 출발 예정 시간 텍스트
    @Published private(set) var myDepartureTimeText: String?
    /// 나의 경로 도착 예정 시간 텍스트
    @Published private(set) var myArrivalTimeText: String?
    /// 나의 경로 남은 시간 텍스트
    @Published private(set) var myRemainingTimeText: String?
    /// 나의 경로 출발 후 경과 시간 텍스트
    @Published private(set) var myElapsedTimeText: String?
    /// 나의 경로를 구성하는 이동수단별 구간 목록
    @Published private(set) var mySteps: [RouteStep] = []
    /// 약속 정보 조회 중 여부
    @Published private(set) var isLoading = false
    /// 조회 실패 시 사용자에게 보여줄 에러 메시지
    @Published private(set) var errorMessage: String?

    private let appointmentId: String
    private let getAppointmentDetailUseCase: GetAppointmentDetailUseCase

    init(appointmentId: String, getAppointmentDetailUseCase: GetAppointmentDetailUseCase) {
        self.appointmentId = appointmentId
        self.getAppointmentDetailUseCase = getAppointmentDetailUseCase
    }

    func fetchAppointmentDetail() {
        isLoading = true
        getAppointmentDetailUseCase.execute(appointmentId: appointmentId) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let value):
                    self.apply(appointment: value.appointment, currentUserId: value.currentUserId)
                case .failure:
                    self.errorMessage = "약속 정보를 불러오지 못했습니다"
                }
            }
        }
    }

    func changeRouteTapped() {
        print("경로 변경 버튼 탭")
    }

    private func apply(appointment: Appointment, currentUserId: String) {
        placeName = appointment.place?.name
        placeCoordinate = appointment.place?.coordinate

        let otherParticipants = appointment.participants.filter { $0.id != currentUserId }
        let orderedParticipants = appointment.participants.first(where: { $0.id == currentUserId })
            .map { [$0] + otherParticipants } ?? otherParticipants

        participants = orderedParticipants.compactMap { user in
            guard let route = appointment.routes[user.id] else { return nil }
            return AppointmentRouteParticipant(user: user, route: route, currentUserId: currentUserId)
        }

        if let myRoute = appointment.routes[currentUserId] {
            myDepartureTimeText = myRoute.departureTime.koreanTimeString
            myArrivalTimeText = myRoute.arrivalTime.koreanTimeString
            myRemainingTimeText = myRoute.arrivalTime.minutesRemainingText
            myElapsedTimeText = myRoute.departureTime.elapsedMinutesText
            mySteps = myRoute.step
        }
    }

}
