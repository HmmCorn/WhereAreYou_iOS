//
//  ProfileImageLoader.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-13.
//

import UIKit

/// 프로필 이미지를 로드해 UIImage로 변환하는 싱글턴 로더
final class ProfileImageLoader {

    static let shared = ProfileImageLoader()

    private let repository: ProfileImageRepository

    private init() {
        repository = DIContainer.shared.resolve(ProfileImageRepository.self)
    }

    func fetchAvailableImageNames() async throws -> [String] {
        try await repository.fetchAvailableImageNames()
    }

    func load(identifier: String) async -> UIImage {
        do {
            let data = try await repository.downloadImageData(identifier: identifier)
            return UIImage(data: data) ?? Self.failureImage
        } catch {
            return Self.failureImage
        }
    }

    // MARK: - 실패 이미지

    static let failureImage: UIImage = {
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let symbol = UIImage(systemName: "questionmark.circle", withConfiguration: config)
        return symbol?.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal)
            ?? UIImage()
    }()

}
