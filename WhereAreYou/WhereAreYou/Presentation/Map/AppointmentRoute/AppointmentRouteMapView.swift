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
        placeMarker?.mapView = nil

        let kind = MapMarker.Kind.place
        let markerImage = MapMarker.renderImage(kind: kind, name: name)

        let marker = NMFMarker(position: NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude))
        marker.iconImage = NMFOverlayImage(image: markerImage)
        marker.width = MapMarker.size(for: kind).width
        marker.height = MapMarker.size(for: kind).height
        marker.anchor = MapMarker.anchor(for: kind)
        marker.mapView = mapView

        placeMarker = marker

        if !hasMovedToInitialPosition {
            hasMovedToInitialPosition = true
            moveCamera(to: coordinate)
        }
    }

    func setParticipants(_ participants: [AppointmentRouteParticipant]) {
        clearParticipantOverlays()

        let colors = UIColor.participantColors(count: participants.count)
        for (index, participant) in participants.enumerated() {
            addPolyline(for: participant, color: colors[index])
            addMarker(for: participant, color: colors[index])
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

    func addMarker(for participant: AppointmentRouteParticipant, color: UIColor) {
        guard let position = participant.path.first else { return }

        let kind = MapMarker.Kind.participant(
            profileImage: UIImage(named: participant.profileImageURL.host ?? ""),
            tintColor: color
        )
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
