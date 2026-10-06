//
//  AppointmentRouteMapView.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/31/26.
//

import UIKit
import NMapsMap

final class AppointmentRouteMapView: NMFNaverMapView {

    /// 지도에 표시된 참여자 마커 — 클러스터링 시 식별자로 개별 제어
    private struct ParticipantMarker {
        let id: String
        let coordinate: Coordinate
        let marker: NMFMarker
        /// 클러스터 마커에 표시할 정보
        let member: ClusterMarkerView.Member
    }

    /// 지도에 표시된 클러스터 마커 — 멤버 구성이 같으면 재사용
    private struct ClusterMarker {
        let memberIDs: [String]
        let marker: NMFMarker
        let images: [UIImage]
        let icons: [NMFOverlayImage]
        var currentIndex = 0
    }

    /// 마커가 겹칠 때의 우선순위 — 클러스터 > 개별 참여자 > 목적지
    private enum MarkerZIndex {
        static let place = 0
        static let participant = 1
        static let cluster = 2
    }

    /// 겹침 판정에 쓰는 참여자 마커 크기
    private static let participantMarkerSize = MapMarker.size(for: .participant(profileImage: nil, tintColor: .clear))
    /// 클러스터 대표 멤버가 바뀌는 주기
    private static let clusterRotationInterval: Duration = .seconds(2)
    /// 대표 멤버가 바뀌는 슬라이드 전환 시간
    private static let clusterTransitionDuration: CFTimeInterval = 0.35

    private var placeMarker: NMFMarker?
    private var participantMarkers: [ParticipantMarker] = []
    private var clusterMarkers: [ClusterMarker] = []
    private var participantPolylines: [NMFPolylineOverlay] = []
    private var placeMarkerLoadTask: Task<Void, Never>?
    private var markerLoadTask: Task<Void, Never>?
    private var clusterRotationTask: Task<Void, Never>?
    private var clusterTransitionLink: CADisplayLink?
    private var clusterTransitionStart: CFTimeInterval = 0
    private var placeCoordinate: Coordinate?
    private var hasMovedToInitialPosition = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    // MARK: - Lifecycle

    override func didMoveToWindow() {
        super.didMoveToWindow()
        updateClusterRotation()
    }

    // MARK: - Public

    func setPlaceMarker(coordinate: Coordinate, name: String) {
        placeMarkerLoadTask?.cancel()
        placeMarker?.mapView = nil

        placeMarkerLoadTask = Task { [weak self] in
            let pinImage = await AppAssetImageLoader.shared.load(.pin)
            guard !Task.isCancelled else { return }
            self?.addPlaceMarker(coordinate: coordinate, name: name, pinImage: pinImage)
        }

        placeCoordinate = coordinate
    }

    func setParticipants(_ participants: [AppointmentRouteParticipant]) {
        markerLoadTask?.cancel()
        clearParticipantOverlays()

        let colors = UIColor.participantColors(count: participants.count)
        for (index, participant) in participants.enumerated() {
            addPolyline(for: participant, color: colors[index])
        }

        markerLoadTask = Task { [weak self] in
            let images = await self?.loadProfileImages(for: participants) ?? []
            guard !Task.isCancelled, !images.isEmpty else { return }

            for (index, participant) in participants.enumerated() {
                self?.addMarker(for: participant, color: colors[index], profileImage: images[index])
            }
            self?.updateClusters()
        }

        moveToInitialPositionIfNeeded(participants: participants)
    }

}

// MARK: - Private

private extension AppointmentRouteMapView {

    // MARK: - Setup

    func setUp() {
        showLocationButton = true
        showScaleBar = false
        showZoomControls = true
        mapView.addCameraDelegate(delegate: self)
    }

    // MARK: - Clustering

    func updateClusters() {
        let items = participantMarkers.map { participantMarker in
            let coordinate = participantMarker.coordinate
            return ParticipantClusterer.Item(
                id: participantMarker.id,
                coordinate: coordinate,
                screenPoint: mapView.projection.point(
                    from: NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)
                )
            )
        }
        let clusters = ParticipantClusterer(markerSize: Self.participantMarkerSize).cluster(items)
        applyClusters(clusters)
    }

    /// 묶인 참여자는 개별 마커를 숨기고 클러스터 마커로 대체
    func applyClusters(_ clusters: [ParticipantClusterer.Cluster]) {
        let groupedClusters = clusters.filter { $0.memberIDs.count > 1 }
        let groupedIDs = Set(groupedClusters.flatMap(\.memberIDs))

        participantMarkers.forEach { $0.marker.hidden = groupedIDs.contains($0.id) }
        updateClusterMarkers(for: groupedClusters)
    }

    func updateClusterMarkers(for groupedClusters: [ParticipantClusterer.Cluster]) {
        var staleMarkers = clusterMarkers
        clusterMarkers = groupedClusters.map { cluster in
            if let index = staleMarkers.firstIndex(where: { $0.memberIDs == cluster.memberIDs }) {
                return staleMarkers.remove(at: index)
            }
            return makeClusterMarker(for: cluster)
        }
        staleMarkers.forEach { $0.marker.mapView = nil }
        updateClusterRotation()
    }

    private func makeClusterMarker(for cluster: ParticipantClusterer.Cluster) -> ClusterMarker {
        let members = cluster.memberIDs.compactMap { id in
            participantMarkers.first { $0.id == id }?.member
        }
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
        marker.zIndex = MarkerZIndex.cluster
        marker.mapView = mapView

        return ClusterMarker(memberIDs: cluster.memberIDs, marker: marker, images: images, icons: icons)
    }

    // MARK: - Cluster Rotation

    /// 클러스터가 있고 화면에 떠 있을 때만 순회를 돌리고, 아니면 정지
    func updateClusterRotation() {
        guard !clusterMarkers.isEmpty, window != nil else {
            cancelClusterTransition()
            clusterRotationTask?.cancel()
            clusterRotationTask = nil
            return
        }
        guard clusterRotationTask == nil else { return }

        clusterRotationTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: Self.clusterRotationInterval)
                guard !Task.isCancelled, let self else { return }
                self.rotateClusterMembers()
            }
        }
    }

    /// 동작 줄이기가 켜져 있으면 바로 교체하고, 아니면 슬라이드 전환
    func rotateClusterMembers() {
        if UIAccessibility.isReduceMotionEnabled {
            showNextClusterMembers()
        } else {
            startClusterTransition()
        }
    }

    func startClusterTransition() {
        guard clusterTransitionLink == nil else { return }

        let link = CADisplayLink(target: self, selector: #selector(updateClusterTransition))
        link.preferredFrameRateRange = CAFrameRateRange(minimum: 20, maximum: 30, preferred: 30)
        link.add(to: .main, forMode: .common)
        clusterTransitionLink = link
        clusterTransitionStart = CACurrentMediaTime()
    }

    @objc func updateClusterTransition() {
        let elapsed = (CACurrentMediaTime() - clusterTransitionStart) / Self.clusterTransitionDuration
        guard elapsed < 1 else {
            finishClusterTransition()
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
    func finishClusterTransition() {
        clusterTransitionLink?.invalidate()
        clusterTransitionLink = nil
        showNextClusterMembers()
    }

    /// 전환을 중단하고 현재 멤버의 정지 아이콘으로 복원
    func cancelClusterTransition() {
        guard let link = clusterTransitionLink else { return }
        link.invalidate()
        clusterTransitionLink = nil
        for clusterMarker in clusterMarkers where clusterMarker.icons.indices.contains(clusterMarker.currentIndex) {
            clusterMarker.marker.iconImage = clusterMarker.icons[clusterMarker.currentIndex]
        }
    }

    func showNextClusterMembers() {
        for index in clusterMarkers.indices where clusterMarkers[index].icons.count > 1 {
            let nextIndex = (clusterMarkers[index].currentIndex + 1) % clusterMarkers[index].icons.count
            clusterMarkers[index].currentIndex = nextIndex
            clusterMarkers[index].marker.iconImage = clusterMarkers[index].icons[nextIndex]
        }
    }

    // MARK: - Camera

    func moveToInitialPositionIfNeeded(participants: [AppointmentRouteParticipant]) {
        guard !hasMovedToInitialPosition, let placeCoordinate else { return }
        hasMovedToInitialPosition = true

        let participantPath = participants.flatMap(\.path)
        fitCamera(to: [placeCoordinate] + participantPath, maxZoom: MapZoom.overview)
    }

    // MARK: - Overlay Building

    func addPolyline(for participant: AppointmentRouteParticipant, color: UIColor) {
        guard participant.path.count >= 2 else { return }

        let points = participant.path.map { NMGLatLng(lat: $0.latitude, lng: $0.longitude) }
        guard let overlay = NMFPolylineOverlay(points) else { return }

        overlay.width = 3
        overlay.color = color
        overlay.pattern = [6, 4]
        overlay.capType = .round
        overlay.mapView = mapView

        participantPolylines.append(overlay)
    }

    func loadProfileImages(for participants: [AppointmentRouteParticipant]) async -> [UIImage] {
        await withTaskGroup(of: (Int, UIImage).self) { group in
            for (index, participant) in participants.enumerated() {
                group.addTask {
                    let image = await ProfileImageLoader.shared.load(identifier: participant.profileImage)
                    return (index, image)
                }
            }

            var images = [UIImage](repeating: ProfileImageLoader.failureImage, count: participants.count)
            for await (index, image) in group {
                images[index] = image
            }
            return images
        }
    }

    @MainActor
    func addPlaceMarker(coordinate: Coordinate, name: String, pinImage: UIImage?) {
        let kind = MapMarker.Kind.place(pinImage: pinImage)
        let markerImage = MapMarker.renderImage(kind: kind, name: name)

        let marker = NMFMarker(position: NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude))
        marker.iconImage = NMFOverlayImage(image: markerImage)
        marker.width = MapMarker.size(for: kind).width
        marker.height = MapMarker.size(for: kind).height
        marker.anchor = MapMarker.anchor(for: kind)
        marker.zIndex = MarkerZIndex.place
        marker.mapView = mapView

        placeMarker = marker
    }

    @MainActor
    func addMarker(for participant: AppointmentRouteParticipant, color: UIColor, profileImage: UIImage) {
        guard let position = participant.path.first else { return }

        let kind = MapMarker.Kind.participant(profileImage: profileImage, tintColor: color)
        let markerImage = MapMarker.renderImage(kind: kind, name: participant.nickname)

        let marker = NMFMarker(position: NMGLatLng(lat: position.latitude, lng: position.longitude))
        marker.iconImage = NMFOverlayImage(image: markerImage)
        marker.width = MapMarker.size(for: kind).width
        marker.height = MapMarker.size(for: kind).height
        marker.anchor = MapMarker.anchor(for: kind)
        marker.zIndex = MarkerZIndex.participant
        marker.mapView = mapView

        participantMarkers.append(
            ParticipantMarker(
                id: participant.id,
                coordinate: position,
                marker: marker,
                member: ClusterMarkerView.Member(
                    nickname: participant.nickname,
                    profileImage: profileImage,
                    tintColor: color
                )
            )
        )
    }

    func clearParticipantOverlays() {
        participantMarkers.forEach { $0.marker.mapView = nil }
        participantMarkers.removeAll()
        clusterMarkers.forEach { $0.marker.mapView = nil }
        clusterMarkers.removeAll()
        updateClusterRotation()
        participantPolylines.forEach { $0.mapView = nil }
        participantPolylines.removeAll()
    }

}

// MARK: - NMFMapViewCameraDelegate

extension AppointmentRouteMapView: NMFMapViewCameraDelegate {

    func mapViewCameraIdle(_ mapView: NMFMapView) {
        updateClusters()
    }

}
