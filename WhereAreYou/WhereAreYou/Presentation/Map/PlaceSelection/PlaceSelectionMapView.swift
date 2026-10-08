//
//  PlaceSelectionMapView.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/30/26.
//

import UIKit
import NMapsMap

final class PlaceSelectionMapView: NMFNaverMapView {

    /// 카메라 이동이 멈추면 핀이 가리키는 좌표와 현재 줌 레벨을 전달
    var onCameraIdle: ((Coordinate, Double) -> Void)?

    private let centerPinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .customRed
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    private func setUp() {
        showZoomControls = true
        showLocationButton = true
        mapView.addCameraDelegate(delegate: self)
        setUpCenterPin()
    }

    private func setUpCenterPin() {
        centerPinImageView.setAppAsset(.pin, renderingMode: .alwaysTemplate)
        centerPinImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(centerPinImageView)

        NSLayoutConstraint.activate([
            centerPinImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerPinImageView.bottomAnchor.constraint(equalTo: centerYAnchor),
            centerPinImageView.widthAnchor.constraint(equalToConstant: 32),
            centerPinImageView.heightAnchor.constraint(equalToConstant: 32),
        ])
    }

    func moveCamera(to coordinate: Coordinate, zoomLevel: Double = 16) {
        let cameraPosition = NMFCameraPosition(
            NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude),
            zoom: zoomLevel
        )
        mapView.moveCamera(NMFCameraUpdate(position: cameraPosition))
    }

}

// MARK: - NMFMapViewCameraDelegate

extension PlaceSelectionMapView: NMFMapViewCameraDelegate {

    func mapViewCameraIdle(_ mapView: NMFMapView) {
        let pinPoint = centerPinImageView.convert(
            CGPoint(x: centerPinImageView.bounds.midX, y: centerPinImageView.bounds.maxY),
            to: mapView
        )
        let coordinate = mapView.projection.latlng(from: pinPoint)
        onCameraIdle?(Coordinate(latitude: coordinate.lat, longitude: coordinate.lng), mapView.zoomLevel)
    }

}
