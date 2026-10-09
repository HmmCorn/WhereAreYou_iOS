//
//  Coordinate+Distance.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/27/26.
//

import Foundation

extension Coordinate {

    /// Haversine 공식을 이용해 두 좌표 사이의 거리를 km 단위로 계산
    /// 거리 = 지구 반지름 * centralAngle (호의 길이 = 반지름 * 중심각(라디안))
    func distance(to other: Coordinate) -> Double {
        let earthRadiusKm = 6371.0

        let lat1 = latitude * .pi / 180
        let lat2 = other.latitude * .pi / 180
        let deltaLat = (other.latitude - latitude) * .pi / 180
        let deltaLon = (other.longitude - longitude) * .pi / 180

        let centralAngleFactor = sin(deltaLat / 2) * sin(deltaLat / 2)
            + cos(lat1) * cos(lat2) * sin(deltaLon / 2) * sin(deltaLon / 2)
        let centralAngle = 2 * atan2(sqrt(centralAngleFactor), sqrt(1 - centralAngleFactor))

        return earthRadiusKm * centralAngle
    }

}
