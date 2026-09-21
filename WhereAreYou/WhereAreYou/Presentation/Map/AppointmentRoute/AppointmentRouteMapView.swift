//
//  AppointmentRouteMapView.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/31/26.
//

import UIKit
import NMapsMap

final class AppointmentRouteMapView: NMFNaverMapView {

    private var placeMarker: NMFMarker?
    private var participantMarkers: [NMFMarker] = []
    private var participantPolylines: [NMFPolylineOverlay] = []
    private var placeMarkerLoadTask: Task<Void, Never>?
    private var markerLoadTask: Task<Void, Never>?
    private var hasMovedToInitialPosition = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    // MARK: - Public

    func moveCamera(to coordinate: Coordinate, zoomLevel: Double = 15) {
        let cameraPosition = NMFCameraPosition(
            NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude),
            zoom: zoomLevel
        )
        mapView.moveCamera(NMFCameraUpdate(position: cameraPosition))
    }

    func setPlaceMarker(coordinate: Coordinate, name: String) {
        placeMarkerLoadTask?.cancel()
        placeMarker?.mapView = nil

        placeMarkerLoadTask = Task { [weak self] in
            let pinImage = await AppAssetImageLoader.shared.load(.pin)
            guard !Task.isCancelled else { return }
            self?.addPlaceMarker(coordinate: coordinate, name: name, pinImage: pinImage)
        }

        if !hasMovedToInitialPosition {
            hasMovedToInitialPosition = true
            moveCamera(to: coordinate)
        }
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
        }
    }

}

// MARK: - Private

private extension AppointmentRouteMapView {

    // MARK: - Setup

    func setUp() {
        showLocationButton = true
        showScaleBar = false
        showZoomControls = true
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

    func addPlaceMarker(coordinate: Coordinate, name: String, pinImage: UIImage?) {
        let kind = MapMarker.Kind.place(pinImage: pinImage)
        let markerImage = MapMarker.renderImage(kind: kind, name: name)

        let marker = NMFMarker(position: NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude))
        marker.iconImage = NMFOverlayImage(image: markerImage)
        marker.width = MapMarker.size(for: kind).width
        marker.height = MapMarker.size(for: kind).height
        marker.anchor = MapMarker.anchor(for: kind)
        marker.mapView = mapView

        placeMarker = marker
    }

    func addMarker(for participant: AppointmentRouteParticipant, color: UIColor, profileImage: UIImage) {
        guard let position = participant.path.first else { return }

        let kind = MapMarker.Kind.participant(profileImage: profileImage, tintColor: color)
        let markerImage = MapMarker.renderImage(kind: kind, name: participant.nickname)

        let marker = NMFMarker(position: NMGLatLng(lat: position.latitude, lng: position.longitude))
        marker.iconImage = NMFOverlayImage(image: markerImage)
        marker.width = MapMarker.size(for: kind).width
        marker.height = MapMarker.size(for: kind).height
        marker.anchor = MapMarker.anchor(for: kind)
        marker.mapView = mapView

        participantMarkers.append(marker)
    }

    func clearParticipantOverlays() {
        participantMarkers.forEach { $0.mapView = nil }
        participantMarkers.removeAll()
        participantPolylines.forEach { $0.mapView = nil }
        participantPolylines.removeAll()
    }

}
