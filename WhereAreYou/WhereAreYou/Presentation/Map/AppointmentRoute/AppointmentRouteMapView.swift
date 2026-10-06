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

    /// 마커가 겹칠 때의 우선순위 — 클러스터 > 개별 참여자 > 목적지
    private enum MarkerZIndex {
        static let place = 0
        static let participant = 1
        static let cluster = 2
    }

    /// 겹침 판정에 쓰는 참여자 마커 크기
    private static let participantMarkerSize = MapMarker.size(for: .participant(profileImage: nil, tintColor: .clear))

    private lazy var clusterController = ClusterMarkerController(mapView: mapView, zIndex: MarkerZIndex.cluster)
    private var placeMarker: NMFMarker?
    private var participantMarkers: [ParticipantMarker] = []
    private var participantPolylines: [NMFPolylineOverlay] = []
    private var placeMarkerLoadTask: Task<Void, Never>?
    private var markerLoadTask: Task<Void, Never>?
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
        clusterController.setActive(window != nil)
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
        clusterController.update(clusters: groupedClusters) { id in
            participantMarkers.first { $0.id == id }?.member
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
        clusterController.removeAll()
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
