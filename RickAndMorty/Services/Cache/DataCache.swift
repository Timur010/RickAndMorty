//
//  DataCache.swift
//  RickAndMorty
//
//  Created by Timur Kadiev on 11.01.2025.
//

import Foundation

final class DataCache: CacheManager<Data> {
    static let shared = DataCache()
    
    private init() {
        super.init(
            folderName: "DataCache",
            maxItems: 100,
            maxSize: 10 * 1024 * 1024,
            timeToLive: 60 * 60
        )
    }
    
    func getData<T: Codable>(for key: String, completion: @escaping (T?) -> Void) {
        if let cachedData = getFromMemoryCache(for: key),
           let decoded = try? JSONDecoder().decode(T.self, from: cachedData) {
            completion(decoded)
            return
        }
        
        let filePath = diskCachePath + "/" + key.hash.description
        diskCacheQueue.async { [weak self] in
            guard let self = self else { return }
            
            if let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
               let decoded = try? JSONDecoder().decode(T.self, from: data) {
                self.saveToMemoryCache(data, for: key)
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
    
    func cacheData<T: Codable>(_ item: T, for key: String) {
        guard let data = try? JSONEncoder().encode(item) else { return }
        
        saveToMemoryCache(data, for: key)
        
        diskCacheQueue.async { [weak self] in
            guard let self = self else { return }
            
            let filePath = self.diskCachePath + "/" + key.hash.description
            try? data.write(to: URL(fileURLWithPath: filePath))
            self.cleanupDiskCacheIfNeeded()
        }
    }
}
