//
//  ClusterMarkerController.swift
//  WhereAreYou
//
//  Created by 김성훈 on 10/6/26.
//

import UIKit
import NMapsMap

/// 클러스터 마커의 표시, 멤버 순환, 슬라이드 전환 관리
final class ClusterMarkerController: NSObject {

    /// 지도에 표시된 클러스터 마커 — 멤버 구성이 같으면 재사용
    private struct ClusterMarker {
        let memberIDs: [String]
        let marker: NMFMarker
        /// 멤버별 정지 이미지 — 전환 프레임의 재료
        let images: [UIImage]
        let icons: [NMFOverlayImage]
        var currentIndex = 0
    }

    /// 클러스터 대표 멤버가 바뀌는 주기
    private static let rotationInterval: Duration = .seconds(2)
    /// 대표 멤버가 바뀌는 슬라이드 전환 시간
    private static let transitionDuration: CFTimeInterval = 0.35

    private weak var mapView: NMFMapView?
    private let zIndex: Int
    private var clusterMarkers: [ClusterMarker] = []
    private var isActive = false
    private var rotationTask: Task<Void, Never>?
    private var transitionLink: CADisplayLink?
    private var transitionStart: CFTimeInterval = 0

    init(mapView: NMFMapView, zIndex: Int) {
        self.mapView = mapView
        self.zIndex = zIndex
        super.init()
    }

    // MARK: - Public

    /// 클러스터 목록에 맞춰 마커를 갱신 — 멤버 구성이 같은 클러스터는 기존 마커 재사용
    func update(clusters: [ParticipantClusterer.Cluster], member: (String) -> ClusterMarkerView.Member?) {
        var staleMarkers = clusterMarkers
        clusterMarkers = clusters.map { cluster in
            if let index = staleMarkers.firstIndex(where: { $0.memberIDs == cluster.memberIDs }) {
                return staleMarkers.remove(at: index)
            }
            return makeClusterMarker(for: cluster, members: cluster.memberIDs.compactMap(member))
        }
        staleMarkers.forEach { $0.marker.mapView = nil }
        updateRotation()
    }

    /// 화면 표시 여부 — 표시 중일 때만 순환 동작
    func setActive(_ isActive: Bool) {
        self.isActive = isActive
        updateRotation()
    }

    func removeAll() {
        clusterMarkers.forEach { $0.marker.mapView = nil }
        clusterMarkers.removeAll()
        updateRotation()
    }

}

// MARK: - Private

private extension ClusterMarkerController {

    private func makeClusterMarker(for cluster: ParticipantClusterer.Cluster, members: [ClusterMarkerView.Member]) -> ClusterMarker {
        let images = members.indices.map { index in
            ClusterMarkerView.renderImage(members: members, memberIndex: index)
        }
        let icons = images.map { NMFOverlayImage(image: $0) }

        let coordinate = cluster.coordinate
        let marker = NMFMarker(position: NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude))
        if let firstIcon = icons.first {
            marker.iconImage = firstIcon
        }
        marker.width = ClusterMarkerView.size.width
        marker.height = ClusterMarkerView.size.height
        marker.anchor = ClusterMarkerView.anchor
        marker.zIndex = zIndex
        marker.mapView = mapView

        return ClusterMarker(memberIDs: cluster.memberIDs, marker: marker, images: images, icons: icons)
    }

    // MARK: - Rotation

    /// 클러스터가 있고 화면에 떠 있을 때만 순환을 돌리고, 아니면 정지
    func updateRotation() {
        guard !clusterMarkers.isEmpty, isActive else {
            cancelTransition()
            rotationTask?.cancel()
            rotationTask = nil
            return
        }
        guard rotationTask == nil else { return }

        rotationTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: Self.rotationInterval)
                guard !Task.isCancelled, let self else { return }
                self.rotateMembers()
            }
        }
    }

    /// 동작 줄이기가 켜져 있으면 바로 교체하고, 아니면 슬라이드 전환
    func rotateMembers() {
        if UIAccessibility.isReduceMotionEnabled {
            showNextMembers()
        } else {
            startTransition()
        }
    }

    // MARK: - Transition

    func startTransition() {
        guard transitionLink == nil else { return }

        let link = CADisplayLink(target: self, selector: #selector(updateTransition))
        link.preferredFrameRateRange = CAFrameRateRange(minimum: 20, maximum: 30, preferred: 30)
        link.add(to: .main, forMode: .common)
        transitionLink = link
        transitionStart = CACurrentMediaTime()
    }

    @objc func updateTransition() {
        let elapsed = (CACurrentMediaTime() - transitionStart) / Self.transitionDuration
        guard elapsed < 1 else {
            finishTransition()
            return
        }

        // 가속 후 감속
        let progress = elapsed * elapsed * (3 - 2 * elapsed)
        for clusterMarker in clusterMarkers where clusterMarker.images.count > 1 {
            let nextIndex = (clusterMarker.currentIndex + 1) % clusterMarker.images.count
            let frame = ClusterMarkerView.renderTransitionFrame(
                from: clusterMarker.images[clusterMarker.currentIndex],
                to: clusterMarker.images[nextIndex],
                progress: progress
            )
            clusterMarker.marker.iconImage = NMFOverlayImage(image: frame)
        }
    }

    /// 전환을 끝내고 다음 멤버로 확정
    func finishTransition() {
        transitionLink?.invalidate()
        transitionLink = nil
        showNextMembers()
    }

    /// 전환을 중단하고 현재 멤버의 정지 아이콘으로 복원
    func cancelTransition() {
        guard let link = transitionLink else { return }
        link.invalidate()
        transitionLink = nil
        for clusterMarker in clusterMarkers where clusterMarker.icons.indices.contains(clusterMarker.currentIndex) {
            clusterMarker.marker.iconImage = clusterMarker.icons[clusterMarker.currentIndex]
        }
    }

    func showNextMembers() {
        for index in clusterMarkers.indices where clusterMarkers[index].icons.count > 1 {
            let nextIndex = (clusterMarkers[index].currentIndex + 1) % clusterMarkers[index].icons.count
            clusterMarkers[index].currentIndex = nextIndex
            clusterMarkers[index].marker.iconImage = clusterMarkers[index].icons[nextIndex]
        }
    }

}
