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
    /// loadTasks 동시 접근 보호용 lock
    private let loadTasksLock = NSLock()
    /// asset별 진행 중인 로드 Task
    private var loadTasks: [AppAsset: Task<AppAssetData, Error>] = [:]

    func loadValidatedImageData(_ asset: AppAsset, isValid: (Data) -> Bool) async throws -> Data {
        let result = try await loadImageData(asset)

        guard isValid(result.data) else {
            if result.isAlreadyCached {
                invalidateCache(asset)
            }
            throw AppAssetValidationError.invalidData
        }

        commitCache(asset, data: result)
        return result.data
    }

    // MARK: - Private

    private func loadImageData(_ asset: AppAsset) async throws -> AppAssetData {
        let key = cacheFileName(for: asset) as NSString
        if let cached = memoryCache.object(forKey: key) {
            return AppAssetData(data: cached as Data, remoteHash: nil, isAlreadyCached: true)
        }

        let task = existingOrNewLoadTask(for: asset)

        do {
            let result = try await task.value
            removeLoadTask(for: asset)
            return result
        } catch {
            removeLoadTask(for: asset)
            throw error
        }
    }

    private func commitCache(_ asset: AppAsset, data: AppAssetData) {
        // 디스크 캐시 히트로 얻은 데이터라도 메모리 캐시엔 아직 없을 수 있으므로 항상 저장
        memoryCache.setObject(data.data as NSData, forKey: cacheFileName(for: asset) as NSString)

        guard !data.isAlreadyCached else { return }

        try? data.data.write(to: cacheFileURL(for: asset), options: .atomic)
        if let remoteHash = data.remoteHash {
            userDefaults.set(remoteHash, forKey: cachedHashKey(for: asset))
        }
    }

    private func invalidateCache(_ asset: AppAsset) {
        memoryCache.removeObject(forKey: cacheFileName(for: asset) as NSString)
        userDefaults.removeObject(forKey: cachedHashKey(for: asset))
        try? fileManager.removeItem(at: cacheFileURL(for: asset))
    }

    private func existingOrNewLoadTask(for asset: AppAsset) -> Task<AppAssetData, Error> {
        loadTasksLock.lock()
        defer { loadTasksLock.unlock() }

        if let existing = loadTasks[asset] {
            return existing
        }

        let task = Task<AppAssetData, Error> { [weak self] in
            guard let self else { throw CancellationError() }
            return try await self.fetchData(for: asset)
        }
        loadTasks[asset] = task
        return task
    }

    private func removeLoadTask(for asset: AppAsset) {
        loadTasksLock.lock()
        loadTasks[asset] = nil
        loadTasksLock.unlock()
    }

    /// 디스크 캐시(해시 일치) 또는 원격에서 데이터 조회
    private func fetchData(for asset: AppAsset) async throws -> AppAssetData {
        let ref = storage.reference().child(storagePath(for: asset))
        let remoteHash = try? await ref.getMetadata().md5Hash

        if let remoteHash,
           remoteHash == userDefaults.string(forKey: cachedHashKey(for: asset)),
           let cachedData = try? Data(contentsOf: cacheFileURL(for: asset)) {
            return AppAssetData(data: cachedData, remoteHash: remoteHash, isAlreadyCached: true)
        }

        let data = try await ref.data(maxSize: maxImageSize)
        return AppAssetData(data: data, remoteHash: remoteHash, isAlreadyCached: false)
    }

    private func cacheFileURL(for asset: AppAsset) -> URL {
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return cachesDirectory.appendingPathComponent(cacheFileName(for: asset))
    }

    // MARK: - Asset 경로/키 매핑

    /// Firebase Storage 상의 경로
    private func storagePath(for asset: AppAsset) -> String {
        "app-assets/\(fileName(for: asset)).png"
    }

    /// 디스크 캐시에 저장할 파일명
    private func cacheFileName(for asset: AppAsset) -> String {
        "\(fileName(for: asset)).png"
    }

    /// 원격 해시(md5Hash)를 저장할 UserDefaults 키
    private func cachedHashKey(for asset: AppAsset) -> String {
        "AppAsset.hash.\(fileName(for: asset))"
    }

    private func fileName(for asset: AppAsset) -> String {
        switch asset {
        case .pin:
            return "pin"
        case .logo:
            return "logo"
        case .loginBackground:
            return "loginBackground"
        }
    }

}

/// loadValidatedImageData 검증 실패 시 던지는 에러
private enum AppAssetValidationError: Error {
    case invalidData
}

/// 캐시(디스크/원격) 조회 결과 — 캐시 확정 저장에 필요한 정보 포함
private struct AppAssetData {

    let data: Data
    /// 원격에서 조회한 해시 — 캐시 커밋 시 저장할 값
    let remoteHash: String?
    /// 이미 검증되어 디스크에 저장된 상태인지 여부
    let isAlreadyCached: Bool

}
