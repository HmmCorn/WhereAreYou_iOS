//
//  NMFNaverMapView+Camera.swift
//  WhereAreYou
//
//  Created by 김성훈 on 10/6/26.
//

import NMapsMap

/// 화면 성격별 지도 기본 줌 레벨
enum MapZoom {

    /// 여러 지점을 함께 보는 화면용 줌
    static let overview: Double = 15
    /// 단일 장소를 자세히 보는 화면용 줌
    static let detail: Double = 16

}

extension NMFNaverMapView {

    /// 지정 좌표로 카메라 이동
    func moveCamera(to coordinate: Coordinate, zoomLevel: Double = MapZoom.detail) {
        let cameraPosition = NMFCameraPosition(
            NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude),
            zoom: zoomLevel
        )
        mapView.moveCamera(NMFCameraUpdate(position: cameraPosition))
    }

    /// 모든 좌표가 보이도록 카메라 이동
    func fitCamera(to coordinates: [Coordinate], padding: CGFloat = 60, maxZoom: Double = MapZoom.detail) {
        guard let firstCoordinate = coordinates.first else { return }

        let latLngs = coordinates.map { NMGLatLng(lat: $0.latitude, lng: $0.longitude) }
        let bounds = NMGLatLngBounds(latLngs: latLngs)
        guard bounds.latSpan > 0 || bounds.lngSpan > 0 else {
            moveCamera(to: firstCoordinate, zoomLevel: maxZoom)
            return
        }

        let map = mapView
        map.moveCamera(NMFCameraUpdate(fit: bounds, padding: padding)) { [weak map] isCancelled in
            guard !isCancelled, let map, map.cameraPosition.zoom > maxZoom else { return }
            map.moveCamera(NMFCameraUpdate(zoomTo: maxZoom))
        }
    }

}
