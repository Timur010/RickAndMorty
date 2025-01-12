//
//  CacheManager.swift
//  RickAndMorty
//
//  Created by Timur Kadiev on 11.01.2025.

import Foundation

final class CacheManager {
    
    private let memoryCache = NSCache<NSString, NSData>()
    private let fileManager = FileManager.default
    private let diskCacheQueue: DispatchQueue
    private let cacheFolderName: String
    private let diskCachePath: String
    
    init(folderName: String) {
        self.cacheFolderName = folderName
        self.diskCacheQueue = DispatchQueue(label: "com.rickandmorty.\(folderName)", qos: .background)
        self.diskCachePath = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent(folderName)
            .path

        setupDiskCache()
    }

    /// Создаёт папку для дискового кеша, если она не существует.
    private func setupDiskCache() {
        if !fileManager.fileExists(atPath: diskCachePath) {
            try? fileManager.createDirectory(atPath: diskCachePath, withIntermediateDirectories: true)
        }
    }

    /// Получает данные из кеша памяти.
    /// - Parameter key: Ключ для поиска данных.
    /// - Returns: Данные, если они существуют в кеше памяти.
    func getFromMemoryCache(for key: String) -> Data? {
        return memoryCache.object(forKey: key as NSString) as Data?
    }

    /// Сохраняет данные в кеш памяти.
    /// - Parameters:
    ///   - data: Данные для сохранения.
    ///   - key: Ключ для сохранения данных.
    func saveToMemoryCache(_ data: Data, for key: String) {
        memoryCache.setObject(data as NSData, forKey: key as NSString)
    }

    /// Удаляет данные из кеша памяти.
    /// - Parameter key: Ключ для удаления данных.
    func removeFromMemoryCache(for key: String) {
        memoryCache.removeObject(forKey: key as NSString)
    }

    /// Получает данные из дискового кеша.
    /// - Parameter key: Ключ для поиска данных.
    /// - Returns: Данные, если они существуют в дисковом кеше.
    func getFromDiskCache(for key: String) -> Data? {
        let filePath = diskCachePath + "/" + key.hash.description
        return try? Data(contentsOf: URL(fileURLWithPath: filePath))
    }

    /// Сохраняет данные в дисковый кеш.
    /// - Parameters:
    ///   - data: Данные для сохранения.
    ///   - key: Ключ для сохранения данных.
    func saveToDiskCache(_ data: Data, for key: String) {
        let filePath = diskCachePath + "/" + key.hash.description
        let url = URL(fileURLWithPath: filePath)
        diskCacheQueue.async {
            try? data.write(to: url)
        }
    }

    /// Удаляет данные из дискового кеша.
    /// - Parameter key: Ключ для удаления данных.
    func removeFromDiskCache(for key: String) {
        let filePath = diskCachePath + "/" + key.hash.description
        diskCacheQueue.async {
            try? self.fileManager.removeItem(atPath: filePath)
        }
    }

    /// Очищает кеш для конкретного ключа (из памяти и диска).
    /// - Parameter key: Ключ для очистки кеша.
    func clearCache(for key: String) {
        removeFromMemoryCache(for: key)
        removeFromDiskCache(for: key)
    }

    /// Очищает весь кеш (из памяти и диска).
    func clearAllCache() {
        memoryCache.removeAllObjects()
        diskCacheQueue.async {
            try? self.fileManager.removeItem(atPath: self.diskCachePath)
            self.setupDiskCache()
        }
    }
}

