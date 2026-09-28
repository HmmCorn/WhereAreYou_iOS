//
//  KakaoNearbyPlaceRepository.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/29/26.
//

import Foundation

/// 카카오 카테고리 검색 기반 주변 장소 조회
/// 카테고리 검색은 요청당 카테고리 1개만 지원하므로, 관심 카테고리를 병렬 요청한 뒤 가장 가까운 결과 1개를 선택
/// 지도 이동 1회당 카테고리 수만큼 호출이 발생 — PlaceSelectionViewModel의 디바운스/최소 이동 거리 필터로 호출량을 제한
final class KakaoNearbyPlaceRepository: NearbyPlaceRepository {

    /// 카카오 API가 허용하는 최대 반경(m)
    private static let maximumRadiusMeters = 20000

    /// 조회 대상 카테고리 — PlaceType으로 매핑되는 카테고리만 포함 (KakaoPlaceDocument.placeType 참고)
    private static let categoryCodes: [KakaoCategoryGroupCode] = [
        .subwayStation, .restaurant, .cafe, .hospital, .largeMart, .convenienceStore
    ]

    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchNearbyPlace(coordinate: Coordinate, radiusKm: Double) async throws -> Place? {
        let radiusMeters = min(Int(radiusKm * 1000), Self.maximumRadiusMeters)

        let nearest = try await withThrowingTaskGroup(of: (Place, Double)?.self) { group in
            for code in Self.categoryCodes {
                group.addTask {
                    try await self.nearestDocument(
                        code: code,
                        coordinate: coordinate,
                        radiusMeters: radiusMeters
                    )
                }
            }

            var best: (place: Place, distance: Double)?
            for try await result in group {
                guard let result else { continue }
                if best == nil || result.1 < best!.distance {
                    best = result
                }
            }
            return best
        }

        return nearest?.place
    }

    // MARK: - Private

    /// 카테고리 하나를 조회해 가장 가까운 (Place, 거리) 반환, 실패/결과없음은 nil로 흡수
    private func nearestDocument(
        code: KakaoCategoryGroupCode,
        coordinate: Coordinate,
        radiusMeters: Int
    ) async throws -> (Place, Double)? {
        do {
            let response: KakaoPlaceResponse = try await apiClient.request(
                KakaoLocalEndpoint.category(code: code, coordinate: coordinate, radiusMeters: radiusMeters)
            )
            guard let document = response.documents.first,
                  let place = document.toPlace(),
                  let distance = document.distanceMeters else {
                return nil
            }
            return (place, distance)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            return nil
        }
    }
}
