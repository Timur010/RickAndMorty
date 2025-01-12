// DataCache.swift
// RickAndMorty

import Foundation

protocol DataCacheProtocol {
    func getDataAsync<T: Codable>(for key: String) async -> T?
    func cacheDataAsync<T: Codable>(_ item: T, for key: String) async
    func clearCacheAsync(for key: String) async
    func clearAllCacheAsync() async
}

class DataCache: DataCacheProtocol {
    
    static let shared = DataCache()
    
    private let cacheManager: CacheManager
    private init() {
        self.cacheManager = CacheManager(folderName: "DataCache")
    }

    /// Асинхронно получает декодированные данные из кеша.
    func getDataAsync<T: Codable>(for key: String) async -> T? {
        await withCheckedContinuation { continuation in
            getData(for: key) { (data: T?) in
                continuation.resume(returning: data)
            }
        }
    }

    /// Получает декодированные данные из кеша с использованием замыкания.
    func getData<T: Codable>(for key: String, completion: @escaping (T?) -> Void) {
        if let cachedData = cacheManager.getFromMemoryCache(for: key),
           let decoded = try? JSONDecoder().decode(T.self, from: cachedData) {
            completion(decoded)
            return
        }
        DispatchQueue.global(qos: .background).async {
            if let data = self.cacheManager.getFromDiskCache(for: key),
               let decoded = try? JSONDecoder().decode(T.self, from: data) {
                self.cacheManager.saveToMemoryCache(data, for: key)
                DispatchQueue.main.async {
                    completion(decoded)
                }
                return
            }

            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }

    /// Асинхронно кеширует закодированные данные.
    func cacheDataAsync<T: Codable>(_ item: T, for key: String) async {
        await withCheckedContinuation { continuation in
            cacheData(item, for: key)
            continuation.resume()
        }
    }

    /// Кеширует закодированные данные с использованием замыкания.
    func cacheData<T: Codable>(_ item: T, for key: String) {
        guard let data = try? JSONEncoder().encode(item) else { return }
        cacheManager.saveToMemoryCache(data, for: key)
        cacheManager.saveToDiskCache(data, for: key)
    }

    /// Асинхронно очищает кеш для конкретного ключа.
    func clearCacheAsync(for key: String) async {
        await withCheckedContinuation { continuation in
            clearCache(for: key)
            continuation.resume()
        }
    }

    /// Очищает кеш для конкретного ключа.
    func clearCache(for key: String) {
        cacheManager.clearCache(for: key)
    }

    /// Асинхронно очищает весь кеш.
    func clearAllCacheAsync() async {
        await withCheckedContinuation { continuation in
            clearAllCache()
            continuation.resume()
        }
    }

    /// Очищает весь кеш.
    func clearAllCache() {
        cacheManager.clearAllCache()
    }
}
