//
//  DefaultRouteProgressService.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-27.
//

import Foundation

/// RouteProgressService 구현 — 다음 확인 지점으로 넘기고, 마지막 지점이면 종료한다.
/// 약속 시간 전에 도착하면 약속 시간까지, 지나서 도착하면 1분 뒤까지 화면에 남긴다.
/// 도달 단계는 따로 저장하지 않고 액티비티 상태에만 둔다. 진행 중인 액티비티가 없거나 이미 도착했으면 아무것도 하지 않는다
final class DefaultRouteProgressService: RouteProgressService {

    /// 약속 시간이 지나 도착했을 때 화면에 남겨 두는 시간
    static let dismissalDelayAfterLateArrival: TimeInterval = 60

    private let liveActivityRepository: RouteLiveActivityRepository

    init(liveActivityRepository: RouteLiveActivityRepository) {
        self.liveActivityRepository = liveActivityRepository
    }

    func advance(appointmentID: String) async {
        await advance(appointmentID: appointmentID, now: Date())
    }

    func advance(appointmentID: String, now: Date) async {
        guard let (plan, currentStatus) = liveActivityRepository.current(appointmentID: appointmentID) else { return }

        let reachedIndex = currentStatus.reachedCheckpointCount
        guard plan.checkpoints.indices.contains(reachedIndex) else { return }

        // TODO: 채팅방에 도착 단계 메시지 전송 + 약속 지도에 내 위치 좌표 갱신 (약속·채팅 Firestore 전환 후)
        // 도착 지점은 항상 마지막이어야 한다. 데이터가 어긋나도 액티비티가 끝나지 않고 남는 일이 없도록 마지막 인덱스도 도착으로 본다
        let isArrival = plan.checkpoints[reachedIndex].kind == .arrival || reachedIndex == plan.checkpoints.count - 1
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
