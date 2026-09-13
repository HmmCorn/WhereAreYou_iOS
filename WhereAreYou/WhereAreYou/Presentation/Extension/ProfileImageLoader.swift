//
//  ProfileImageLoader.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-13.
//

import UIKit
import FirebaseStorage

/// Firebase Storage의 avatars/ 디렉토리에서 프로필 이미지를 다운로드·캐싱하고,
/// 사용 가능한 이미지 이름 목록을 관리하는 싱글턴 로더
final class ProfileImageLoader {

    static let shared = ProfileImageLoader()

    /// Storage에 등록된 아바타 이미지 이름 목록 (확장자 제외)
    private(set) var availableImageNames: [String] = []

    private let cache = NSCache<NSString, UIImage>()
    private let storage = Storage.storage()
    private let maxImageSize: Int64 = 1 * 1024 * 1024
    private var availableNamesFetchTask: Task<[String], Error>?

    private init() {}

    // MARK: - 사용 가능한 이미지 목록 조회

    /// Storage의 avatars/ 디렉토리를 조회해 사용 가능한 이미지 이름을 반환한다.
    /// 한 번 조회한 결과는 메모리에 캐싱되어 이후 즉시 반환된다.
    func fetchAvailableImageNames() async throws -> [String] {
        if !availableImageNames.isEmpty {
            return availableImageNames
        }

        if let existing = availableNamesFetchTask {
            return try await existing.value
        }

        let task = Task<[String], Error> {
            let result = try await storage.reference().child("avatars").listAll()
            return result.items
                .map { ($0.name as NSString).deletingPathExtension }
                .sorted()
        }
        availableNamesFetchTask = task

        let names = try await task.value
        availableImageNames = names
        return names
    }

    // MARK: - 이미지 로드

    /// 식별자에 해당하는 프로필 이미지를 반환한다.
    /// 캐시에 있으면 즉시 반환하고, 없으면 Storage에서 다운로드한 뒤 캐싱한다.
    func load(identifier: String) async -> UIImage {
        if let cached = cache.object(forKey: identifier as NSString) {
            return cached
        }

        do {
            let ref = storage.reference().child("avatars/\(identifier).png")
            let data = try await ref.data(maxSize: maxImageSize)

            guard let image = UIImage(data: data) else {
                return Self.failureImage
            }

            cache.setObject(image, forKey: identifier as NSString)
            return image
        } catch {
            return Self.failureImage
        }
    }

    // MARK: - 플레이스홀더

    static let failureImage: UIImage = {
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let symbol = UIImage(systemName: "questionmark.circle", withConfiguration: config)
        return symbol?.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal)
            ?? UIImage()
    }()

}
