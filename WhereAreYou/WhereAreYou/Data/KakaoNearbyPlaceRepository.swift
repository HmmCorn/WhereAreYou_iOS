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

    /// 카테고리 하나 조회 결과 — 결과 없음(정상)과 요청 실패를 구분해 상위에서 정책을 결정할 수 있게 함
    private enum CategoryResult {
        case found(Place, distanceMeters: Double)
        case notFound
        case failed(Error)
    }

    func fetchNearbyPlace(coordinate: Coordinate, radiusKm: Double) async throws -> Place? {
        let radiusMeters = min(Int(radiusKm * 1000), Self.maximumRadiusMeters)

        let results = try await withThrowingTaskGroup(of: CategoryResult.self) { group in
            for code in Self.categoryCodes {
                group.addTask {
                    try await self.nearestDocument(code: code, coordinate: coordinate, radiusMeters: radiusMeters)
                }
            }
            var collected: [CategoryResult] = []
            for try await result in group {
                collected.append(result)
            }
            return collected
        }

        // 카테고리 중 하나라도 성공(결과 유무 무관)했으면 그 결과로 판단.
        // 전부 요청 실패였을 때만 대표로 첫 실패를 throw — 상위(GetNearbyPlaceUseCase)가 역지오코딩 폴백 여부를 판단할 신호로 사용
        var best: (place: Place, distance: Double)?
        var firstFailure: Error?
        var hasSucceeded = false

        for result in results {
            switch result {
            case .found(let place, let distance):
                hasSucceeded = true
                if best == nil || distance < best!.distance {
                    best = (place, distance)
                }
            case .notFound:
                hasSucceeded = true
            case .failed(let error):
                if firstFailure == nil { firstFailure = error }
            }
        }

        if !hasSucceeded, let firstFailure {
            throw firstFailure
        }
        return best?.place
    }

    // MARK: - Private

    /// 카테고리 하나를 조회해 결과 유무/실패를 구분해 반환. 취소는 흡수하지 않고 그대로 다시 throw
    private func nearestDocument(
        code: KakaoCategoryGroupCode,
        coordinate: Coordinate,
        radiusMeters: Int
    ) async throws -> CategoryResult {
        do {
            let response: KakaoPlaceResponse = try await apiClient.request(
                KakaoLocalEndpoint.category(code: code, coordinate: coordinate, radiusMeters: radiusMeters)
            )
            guard let document = response.documents.first,
                  let place = document.toPlace(),
                  let distance = document.distanceMeters else {
                return .notFound
            }
            return .found(place, distanceMeters: distance)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            return .failed(error)
        }
    }
}
