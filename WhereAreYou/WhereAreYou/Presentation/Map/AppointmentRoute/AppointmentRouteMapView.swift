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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    private func setUp() {
        showLocationButton = true
        showScaleBar = true
        showZoomControls = true
    }

    func moveCamera(to coordinate: Coordinate, zoomLevel: Double = 15) {
        let cameraPosition = NMFCameraPosition(
            NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude),
            zoom: zoomLevel
        )
        mapView.moveCamera(NMFCameraUpdate(position: cameraPosition))
    }

    func setPlaceMarker(coordinate: Coordinate, name: String) {
        placeMarker?.mapView = nil

        let marker = NMFMarker(position: NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude))
        marker.iconImage = NMFOverlayImage(image: .pin)
        marker.iconTintColor = .customRed
        marker.width = 32
        marker.height = 32
        marker.anchor = CGPoint(x: 0.5, y: 1.0)
        marker.captionText = name
        marker.captionColor = .label
        marker.captionHaloColor = .systemBackground
        marker.mapView = mapView

        placeMarker = marker
    }

    func setParticipants(_ participants: [AppointmentRouteParticipant]) {
        clearParticipantOverlays()

        for (index, participant) in participants.enumerated() {
            let color = UIColor.participantColor(at: index)
            addPolyline(for: participant, color: color)
            addMarker(for: participant, color: color)
        }
    }

    private func addPolyline(for participant: AppointmentRouteParticipant, color: UIColor) {
        guard participant.path.count >= 2 else { return }

        let points = participant.path.map { NMGLatLng(lat: $0.latitude, lng: $0.longitude) }
        guard let overlay = NMFPolylineOverlay(points) else { return }

        overlay.width = 3
        overlay.color = color
        overlay.pattern = [6, 6]
        overlay.capType = .round
        overlay.mapView = mapView

        participantPolylines.append(overlay)
    }

    private func addMarker(for participant: AppointmentRouteParticipant, color: UIColor) {
        guard let position = participant.path.first else { return }

        let markerImage = ParticipantMarkerView.renderImage(
            profileImage: UIImage(named: participant.profileImageURL.host ?? ""),
            nickname: participant.nickname,
            tintColor: color
        )

        let marker = NMFMarker(position: NMGLatLng(lat: position.latitude, lng: position.longitude))
        marker.iconImage = NMFOverlayImage(image: markerImage)
        marker.width = ParticipantMarkerView.size.width
        marker.height = ParticipantMarkerView.size.height
        marker.anchor = CGPoint(x: 0.5, y: 1.0)
        marker.mapView = mapView

        participantMarkers.append(marker)
    }

    private func clearParticipantOverlays() {
        participantMarkers.forEach { $0.mapView = nil }
        participantMarkers.removeAll()
        participantPolylines.forEach { $0.mapView = nil }
        participantPolylines.removeAll()
    }

}
