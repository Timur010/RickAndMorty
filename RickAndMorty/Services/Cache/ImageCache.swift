//
//  ImageCache.swift
//  RickAndMorty
//
//  Created by Timur Kadiev on 11.01.2025.
//

import UIKit

final class ImageCache: CacheManager<UIImage> {
    static let shared = ImageCache()
    
    private init() {
        super.init(
            folderName: "ImageCache",
            maxItems: 100,
            maxSize: 50 * 1024 * 1024,
            timeToLive: 24 * 60 * 60
        )
        
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearMemoryCache),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    @objc private func clearMemoryCache() {
        memoryCache.removeAllObjects()
    }
    
    func getImage(for url: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = getFromMemoryCache(for: url) {
            completion(cachedImage)
            return
        }
        
        let imagePath = diskCachePath + "/" + url.hash.description
        diskCacheQueue.async { [weak self] in
            guard let self = self else { return }
            
            if let data = try? Data(contentsOf: URL(fileURLWithPath: imagePath)),
               let image = UIImage(data: data) {
                self.saveToMemoryCache(image, for: url)
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
    
    func cacheImage(_ image: UIImage, for url: String) {
        saveToMemoryCache(image, for: url)
        
        diskCacheQueue.async { [weak self] in
            guard let self = self else { return }
            
            let imagePath = self.diskCachePath + "/" + url.hash.description
            if let data = image.jpegData(compressionQuality: 0.8) {
                try? data.write(to: URL(fileURLWithPath: imagePath))
                self.cleanupDiskCacheIfNeeded()
            }
        }
    }
}
