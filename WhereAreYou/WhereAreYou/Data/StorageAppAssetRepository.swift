//
//  StorageAppAssetRepository.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/22/26.
//

import Foundation
import FirebaseStorage

/// Firebase Storage 기반 앱 정적 에셋 저장소
///
/// Storage의 metadata로 원격 버전을 확인하여 로컬 디스크 캐시와 다를 때만 재다운로드
final class StorageAppAssetRepository: AppAssetRepository {

    /// Firebase Storage 참조
    private let storage = Storage.storage()
    /// 다운로드 허용 최대 이미지 크기
    private let maxImageSize: Int64 = 5 * 1024 * 1024
    /// 원격 해시 저장용 UserDefaults
    private let userDefaults = UserDefaults.standard
    /// 디스크 캐시 파일 접근용 FileManager
    private let fileManager = FileManager.default
    /// 다운로드한 이미지 데이터의 메모리 캐시
    private let memoryCache = NSCache<NSString, NSData>()
    /// downloadTasks 동시 접근 보호용 lock
    private let downloadTasksLock = NSLock()
    /// asset별 진행 중인 다운로드 Task
    private var downloadTasks: [AppAsset: Task<Data, Error>] = [:]

    func downloadImageData(_ asset: AppAsset) async throws -> Data {
        let key = asset.cacheFileName as NSString
        if let cached = memoryCache.object(forKey: key) {
            return cached as Data
        }

        let task = existingOrNewDownloadTask(for: asset)

        do {
            let data = try await task.value
            memoryCache.setObject(data as NSData, forKey: key)
            removeDownloadTask(for: asset)
            return data
        } catch {
            removeDownloadTask(for: asset)
            throw error
        }
    }

    func invalidateCache(_ asset: AppAsset) {
        memoryCache.removeObject(forKey: asset.cacheFileName as NSString)
        userDefaults.removeObject(forKey: asset.cachedHashKey)
        try? fileManager.removeItem(at: cacheFileURL(for: asset))
    }

    // MARK: - Private

    private func existingOrNewDownloadTask(for asset: AppAsset) -> Task<Data, Error> {
        downloadTasksLock.lock()
        defer { downloadTasksLock.unlock() }

        if let existing = downloadTasks[asset] {
            return existing
        }

        let task = Task<Data, Error> { [weak self] in
            guard let self else { throw CancellationError() }
            return try await self.fetchData(for: asset)
        }
        downloadTasks[asset] = task
        return task
    }

    private func removeDownloadTask(for asset: AppAsset) {
        downloadTasksLock.lock()
        downloadTasks[asset] = nil
        downloadTasksLock.unlock()
    }

    private func fetchData(for asset: AppAsset) async throws -> Data {
        let ref = storage.reference().child(asset.storagePath)
        let remoteHash = try? await ref.getMetadata().md5Hash

        if let remoteHash,
           remoteHash == userDefaults.string(forKey: asset.cachedHashKey),
           let cachedData = try? Data(contentsOf: cacheFileURL(for: asset)) {
            return cachedData
        }

        let data = try await ref.data(maxSize: maxImageSize)

        try? data.write(to: cacheFileURL(for: asset), options: .atomic)
        if let remoteHash {
            userDefaults.set(remoteHash, forKey: asset.cachedHashKey)
        }

        return data
    }

    private func cacheFileURL(for asset: AppAsset) -> URL {
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return cachesDirectory.appendingPathComponent(asset.cacheFileName)
    }

}
