//
//  LocationPreviewMapView.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/16/26.
//

import UIKit
import NMapsMap

final class LocationPreviewMapView: NMFNaverMapView {

    private var marker: NMFMarker?
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

    func moveCamera(to coordinate: Coordinate, zoomLevel: Double = 16) {
        let cameraPosition = NMFCameraPosition(
            NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude),
            zoom: zoomLevel
        )
        mapView.moveCamera(NMFCameraUpdate(position: cameraPosition))
    }

    func setMarker(coordinate: Coordinate, name: String) {
        marker?.mapView = nil

        let kind = MapMarker.Kind.place
        let markerImage = MapMarker.renderImage(kind: kind, name: name)

        let newMarker = NMFMarker(position: NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude))
        newMarker.iconImage = NMFOverlayImage(image: markerImage)
        newMarker.width = MapMarker.size(for: kind).width
        newMarker.height = MapMarker.size(for: kind).height
        newMarker.anchor = MapMarker.anchor(for: kind)
        newMarker.mapView = mapView

        marker = newMarker

        if !hasMovedToInitialPosition {
            hasMovedToInitialPosition = true
            moveCamera(to: coordinate)
        }
    }

}

// MARK: - Private

private extension LocationPreviewMapView {

    func setUp() {
        showLocationButton = true
        showScaleBar = false
        showZoomControls = true
    }

}
