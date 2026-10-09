//
//  StorageProfileImageRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-14.
//

import Foundation
import FirebaseStorage

/// Firebase Storage 기반 프로필 이미지 저장소
actor StorageProfileImageRepository: ProfileImageRepository {

    private let storage = Storage.storage()
    private let maxImageSize: Int64 = 1 * 1024 * 1024

    private var cachedNames: [String]?
    private var namesFetchTask: Task<[String], Error>?
    private let dataCache = NSCache<NSString, NSData>()

    func fetchAvailableImageNames() async throws -> [String] {
        if let cached = cachedNames {
            return cached
        }

        if let existing = namesFetchTask {
            return try await existing.value
        }

        let storage = self.storage
        let task = Task<[String], Error> {
            let result = try await storage.reference().child("avatars").listAll()
            return result.items
                .map { ($0.name as NSString).deletingPathExtension }
                .sorted()
        }
        namesFetchTask = task

        do {
            let names = try await task.value
            cachedNames = names
            namesFetchTask = nil
            return names
        } catch {
            namesFetchTask = nil
            throw error
        }
    }

    func downloadImageData(identifier: String) async throws -> Data {
        let key = identifier as NSString
        if let cached = dataCache.object(forKey: key) {
            return cached as Data
        }

        let ref = storage.reference().child("avatars/\(identifier).png")
        let data = try await ref.data(maxSize: maxImageSize)
        dataCache.setObject(data as NSData, forKey: key)
        return data
    }

}
