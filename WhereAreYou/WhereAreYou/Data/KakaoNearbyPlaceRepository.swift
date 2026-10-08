//
//  KakaoNearbyPlaceRepository.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/29/26.
//

import Foundation

/// 좌표 반경 내 가장 가까운 장소 1개 조회 (지도 장소 선택, 현재 위치 표시용, 키워드 검색과 무관)
/// 카테고리 검색이 요청당 카테고리 1개만 지원해, 서비스가 다루는 카테고리를 병렬 요청 후 가장 가까운 결과 선택
/// 지도 이동 1회당 카테고리 수만큼 호출 발생 — PlaceSelectionViewModel의 디바운스/최소 이동 거리로 호출량 제한
final class KakaoNearbyPlaceRepository: NearbyPlaceRepository {

    /// 카카오 API가 허용하는 최대 반경(m)
    private static let maximumRadiusMeters = 20000

    /// 조회 대상 카테고리 — 검색 화면 필터와 무관, PlaceType 매핑 대상만 포함
    private static let categoryCodes: [KakaoCategoryGroupCode] = [
        .subwayStation, .restaurant, .cafe, .hospital, .largeMart, .convenienceStore
    ]

    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    /// 카테고리당 수집하는 후보 수
    private static let candidatesPerCategory = 5

    /// 선택 대상 후보
    private struct Candidate {
        let place: Place
        let distanceMeters: Double
        let categoryCode: KakaoCategoryGroupCode
    }

    /// 카테고리 하나 조회 결과 — 결과 없음(정상)과 요청 실패를 구분해 상위에서 정책을 결정할 수 있게 함
    private enum CategoryResult {
        case found([Candidate])
        case notFound
        case failed(Error)
    }

    func fetchNearbyPlace(coordinate: Coordinate, radiusKm: Double) async throws -> Place? {
        let radiusMeters = min(Int(radiusKm * 1000), Self.maximumRadiusMeters)

        let results = try await withThrowingTaskGroup(of: CategoryResult.self) { group in
            for code in Self.categoryCodes {
                group.addTask {
                    try await self.fetchCandidates(code: code, coordinate: coordinate, radiusMeters: radiusMeters)
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
        var candidates: [Candidate] = []
        var firstFailure: Error?
        var hasSucceeded = false

        for result in results {
            switch result {
            case .found(let found):
                hasSucceeded = true
                candidates.append(contentsOf: found)
            case .notFound:
                hasSucceeded = true
            case .failed(let error):
                if firstFailure == nil { firstFailure = error }
            }
        }

        if !hasSucceeded, let firstFailure {
            throw firstFailure
        }
        return candidates.min { $0.distanceMeters < $1.distanceMeters }?.place
    }

    // MARK: - Private

    /// 카테고리 하나의 상위 후보를 조회해 결과 유무/실패를 구분해 반환
    private func fetchCandidates(
        code: KakaoCategoryGroupCode,
        coordinate: Coordinate,
        radiusMeters: Int
    ) async throws -> CategoryResult {
        do {
            let response: KakaoPlaceResponse = try await apiClient.request(
                KakaoLocalEndpoint.category(code: code, coordinate: coordinate, radiusMeters: radiusMeters)
            )
            let candidates = response.documents
                .prefix(Self.candidatesPerCategory)
                .compactMap { document -> Candidate? in
                    guard let place = document.toPlace(),
                          let distance = document.distanceMeters else {
                        return nil
                    }
                    return Candidate(place: place, distanceMeters: distance, categoryCode: code)
                }
            return candidates.isEmpty ? .notFound : .found(candidates)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            return .failed(error)
        }
    }
}
