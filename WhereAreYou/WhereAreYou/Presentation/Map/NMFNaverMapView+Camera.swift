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

}
