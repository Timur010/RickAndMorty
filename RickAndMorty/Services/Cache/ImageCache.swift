// ImageCache.swift
// RickAndMorty

import UIKit

final class ImageCache {

    static let shared = ImageCache()

    private let cacheManager: CacheManager

    private init() {
        self.cacheManager = CacheManager(folderName: "ImageCache")
    }

    /// Асинхронно получает изображение из кеша.
    /// - Parameter url: URL изображения.
    /// - Returns: Изображение, если оно существует в кеше.
    func getImageAsync(for url: String) async -> UIImage? {
        await withCheckedContinuation { continuation in
            getImage(for: url) { image in
                continuation.resume(returning: image)
            }
        }
    }

    /// Получает изображение из кеша с использованием замыкания.
    /// - Parameters:
    ///   - url: URL изображения.
    ///   - completion: Замыкание, вызываемое с результатом поиска.
    func getImage(for url: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = cacheManager.getFromMemoryCache(for: url),
           let image = UIImage(data: cachedImage) {
            completion(image)
            return
        }
        DispatchQueue.global(qos: .background).async {
            if let data = self.cacheManager.getFromDiskCache(for: url),
               let image = UIImage(data: data) {
                self.cacheManager.saveToMemoryCache(data, for: url)
                DispatchQueue.main.async {
                    completion(image)
                }
                return
            }

            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }

    /// Асинхронно кеширует изображение.
    /// - Parameters:
    ///   - image: Изображение для кеширования.
    ///   - url: URL изображения.
    func cacheImageAsync(_ image: UIImage, for url: String) async {
        await withCheckedContinuation { continuation in
            cacheImage(image, for: url)
            continuation.resume()
        }
    }

    /// Кеширует изображение с использованием замыкания.
    /// - Parameters:
    ///   - image: Изображение для кеширования.
    ///   - url: URL изображения.
    func cacheImage(_ image: UIImage, for url: String) {
        // Конвертация UIImage в Data (JPEG с качеством 0.8)
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        cacheManager.saveToMemoryCache(data, for: url)
        cacheManager.saveToDiskCache(data, for: url)
    }

    /// Асинхронно очищает кеш для конкретного изображения.
    /// - Parameter url: URL изображения.
    func clearCacheAsync(for url: String) async {
        await withCheckedContinuation { continuation in
            clearCache(for: url)
            continuation.resume()
        }
    }

    /// Очищает кеш для конкретного изображения.
    /// - Parameter url: URL изображения.
    func clearCache(for url: String) {
        cacheManager.clearCache(for: url)
    }

    /// Асинхронно очищает весь кеш изображений.
    func clearAllCacheAsync() async {
        await withCheckedContinuation { continuation in
            clearAllCache()
            continuation.resume()
        }
    }

    /// Очищает весь кеш изображений.
    func clearAllCache() {
        cacheManager.clearAllCache()
    }
}
