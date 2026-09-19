//
//  ProfileImageRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-14.
//

import Foundation

/// 프로필 이미지 저장소 — 사용 가능한 이미지 목록 조회 및 이미지 데이터 다운로드
protocol ProfileImageRepository {

    func fetchAvailableImageNames() async throws -> [String]

    func downloadImageData(identifier: String) async throws -> Data

}
