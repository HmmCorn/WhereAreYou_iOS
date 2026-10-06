//
//  ParticipantClusterer.swift
//  WhereAreYou
//
//  Created by 김성훈 on 10/6/26.
//

import CoreGraphics

/// 화면 거리 기준 참여자 마커 클러스터링 계산
struct ParticipantClusterer {

    /// 클러스터링 입력 단위
    struct Item {
        let id: String
        let coordinate: Coordinate
        /// 현재 카메라 기준 화면 좌표
        let screenPoint: CGPoint
    }

    /// 클러스터링 결과 단위
    struct Cluster {
        /// 입력 순서를 유지한 멤버 식별자
        let memberIDs: [String]
        /// 멤버 좌표 평균
        let coordinate: Coordinate
    }

    /// 마커 한 개의 화면 크기 — 모든 마커가 같은 크기라는 전제로 이 크기만큼 겹치면 같은 클러스터로 판정
    let markerSize: CGSize

    func cluster(_ items: [Item]) -> [Cluster] {
        var groups: [ClusterGroup] = []

        for item in items {
            if let index = nearestOverlappingGroupIndex(for: item, in: groups) {
                groups[index].members.append(item)
            } else {
                groups.append(ClusterGroup(leader: item, members: [item]))
            }
        }

        return groups.map { makeCluster(from: $0.members) }
    }

}

// MARK: - Private

private extension ParticipantClusterer {

    /// 첫 멤버(기준 마커)를 기준으로 비교하는 그룹
    struct ClusterGroup {
        let leader: Item
        var members: [Item]
    }

    /// 기준 마커와 겹치는 그룹 중 가장 가까운 그룹의 인덱스
    func nearestOverlappingGroupIndex(for item: Item, in groups: [ClusterGroup]) -> Int? {
        groups.indices
            .filter { isOverlapping(item.screenPoint, groups[$0].leader.screenPoint) }
            .min {
                squaredDistance(item.screenPoint, groups[$0].leader.screenPoint)
                    < squaredDistance(item.screenPoint, groups[$1].leader.screenPoint)
            }
    }

    func isOverlapping(_ lhs: CGPoint, _ rhs: CGPoint) -> Bool {
        abs(lhs.x - rhs.x) < markerSize.width && abs(lhs.y - rhs.y) < markerSize.height
    }

    func squaredDistance(_ lhs: CGPoint, _ rhs: CGPoint) -> CGFloat {
        let deltaX = lhs.x - rhs.x
        let deltaY = lhs.y - rhs.y
        return deltaX * deltaX + deltaY * deltaY
    }

    func makeCluster(from members: [Item]) -> Cluster {
        let count = Double(members.count)
        let latitude = members.reduce(0) { $0 + $1.coordinate.latitude } / count
        let longitude = members.reduce(0) { $0 + $1.coordinate.longitude } / count
        return Cluster(
            memberIDs: members.map(\.id),
            coordinate: Coordinate(latitude: latitude, longitude: longitude)
        )
    }

}
