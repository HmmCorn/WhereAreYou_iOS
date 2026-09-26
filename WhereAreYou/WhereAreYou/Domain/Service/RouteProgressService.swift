//
//  RouteProgressService.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-27.
//

import Foundation

/// 약속 이동 진행 처리 — 라이브 액티비티 단계 버튼(LiveActivityIntent)이 화면 없이 부르므로 DI에 등록해 쓴다.
/// 다음 확인 지점으로 넘기고, 도착이면 종료한다. 약속 시간 전에 도착하면 약속 시간까지, 지나서 도착하면 1분 뒤까지 화면에 남긴다.
/// 도달 단계는 따로 저장하지 않고 액티비티 상태에만 둔다. 진행 중인 액티비티가 없거나 이미 도착했으면 아무것도 하지 않는다
final class RouteProgressService {

    /// 약속 시간이 지나 도착했을 때 화면에 남겨 두는 시간
    static let dismissalDelayAfterLateArrival: TimeInterval = 60

    private let liveActivityRepository: RouteLiveActivityRepository

    init(liveActivityRepository: RouteLiveActivityRepository) {
        self.liveActivityRepository = liveActivityRepository
    }

    func advance(appointmentID: String, now: Date = Date()) async {
        guard let (plan, currentStatus) = liveActivityRepository.current(appointmentID: appointmentID) else { return }

        let reachedIndex = currentStatus.reachedCheckpointCount
        guard plan.checkpoints.indices.contains(reachedIndex) else { return }

        // TODO: 채팅방에 도착 단계 메시지 전송 + 약속 지도에 내 위치 좌표 갱신 (약속·채팅 Firestore 전환 후)
        let isArrival = plan.checkpoints[reachedIndex].kind == .arrival
        var status = currentStatus
        status.reachedCheckpointCount = reachedIndex + 1
        if isArrival {
            // TODO: 도착 인원은 서버 데이터가 생긴 뒤 실데이터로 교체
            status.arrivedParticipantCount += 1
            await liveActivityRepository.end(
                appointmentID: appointmentID,
                status: status,
                dismissalDate: max(plan.appointmentTime, now.addingTimeInterval(Self.dismissalDelayAfterLateArrival))
            )
        } else {
            await liveActivityRepository.update(appointmentID: appointmentID, status: status)
        }
    }

}
