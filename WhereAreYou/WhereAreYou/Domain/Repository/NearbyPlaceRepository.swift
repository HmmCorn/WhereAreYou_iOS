//
//  NearbyPlaceRepository.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/27/26.
//

protocol NearbyPlaceRepository {

    /// 좌표 반경 내 가장 가까운 장소 1개를 조회한다
    /// 조회 자체는 성공했으나 반경 내 장소가 없으면 nil을 반환한다 (에러 아님)
    /// 내부적으로 여러 하위 조회로 나뉘는 구현이라면, 그중 일부만 실패했을 때 나머지 결과로 판단하고
    /// throw는 조회 자체가 전혀 성립하지 않았을 때(예: 전부 실패)로 제한해야 한다
    func fetchNearbyPlace(coordinate: Coordinate, radiusKm: Double) async throws -> Place?

}
