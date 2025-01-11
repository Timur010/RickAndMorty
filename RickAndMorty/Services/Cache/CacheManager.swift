//
//  CacheManager.swift
//  RickAndMorty
//
//  Created by Timur Kadiev on 11.01.2025.
//

import Foundation
import UIKit

class CacheManager<T> {
    let memoryCache = NSCache<NSString, AnyObject>()
    let fileManager = FileManager.default
    let diskCacheQueue: DispatchQueue
    
    let maxMemoryCacheCount: Int
    let maxDiskCacheSize: UInt64
    let cacheTimeToLive: TimeInterval
    let cacheFolderName: String
    
    private let memoryWarningThreshold: Double = 0.7
    private var cacheHits: Int = 0
    private let cleanupThreshold: Int = 50
    private var currentItemCount: Int = 0
    
    private var cacheKeys: [String] = []
    
    var diskCachePath: String {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(cacheFolderName).path
    }
        
    init(folderName: String,
         maxItems: Int,
         maxSize: UInt64,
         timeToLive: TimeInterval) {
        self.cacheFolderName = folderName
        self.maxMemoryCacheCount = min(maxItems, 50)
        self.maxDiskCacheSize = maxSize
        self.cacheTimeToLive = timeToLive
        self.diskCacheQueue = DispatchQueue(label: "com.rickandmorty.\(folderName)")
        
        setupCache()
        setupMemoryWarningNotification()
    }
        
    private func setupCache() {
        memoryCache.countLimit = maxMemoryCacheCount
        
        if !fileManager.fileExists(atPath: diskCachePath) {
            try? fileManager.createDirectory(atPath: diskCachePath,
                                           withIntermediateDirectories: true)
        }
    }
    
    private func setupMemoryWarningNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    @objc private func handleMemoryWarning() {
        clearMemoryCache()
    }
        
    func getFromMemoryCache(for key: String) -> T? {
        cacheHits += 1
        checkMemoryUsage()
        return memoryCache.object(forKey: key as NSString) as? T
    }
    
    func saveToMemoryCache(_ item: T, for key: String) {
        memoryCache.setObject(item as AnyObject, forKey: key as NSString)
        if !cacheKeys.contains(key) {
            cacheKeys.append(key)
            currentItemCount += 1
        }
        checkMemoryUsage()
    }
    
    private func checkMemoryUsage() {
        if cacheHits >= cleanupThreshold {
            cacheHits = 0
            clearOldMemoryCache()
        }
        
        let memoryUsed = Double(currentItemCount) / Double(maxMemoryCacheCount)
        if memoryUsed > memoryWarningThreshold {
            clearOldMemoryCache()
        }
    }
    
    private func clearMemoryCache() {
        memoryCache.removeAllObjects()
        cacheKeys.removeAll()
        currentItemCount = 0
        cacheHits = 0
    }
    
    private func clearOldMemoryCache() {
        let itemsToRemove = currentItemCount / 2
        let keysToRemove = Array(cacheKeys.prefix(itemsToRemove))
        
        for key in keysToRemove {
            memoryCache.removeObject(forKey: key as NSString)
            if let index = cacheKeys.firstIndex(of: key) {
                cacheKeys.remove(at: index)
            }
        }
        
        currentItemCount = cacheKeys.count
    }
    
    // MARK: - Disk Cache Methods
    
    func clearCache() {
        memoryCache.removeAllObjects()
        diskCacheQueue.async { [weak self] in
            guard let self = self else { return }
            try? self.fileManager.removeItem(atPath: self.diskCachePath)
            try? self.fileManager.createDirectory(atPath: self.diskCachePath,
                                                withIntermediateDirectories: true)
        }
    }
    
    func cleanupDiskCacheIfNeeded() {
        diskCacheQueue.async { [weak self] in
            guard let self = self else { return }
            
            let resourceKeys: Set<URLResourceKey> = [.creationDateKey, .totalFileAllocatedSizeKey]
            let fileEnumerator = self.fileManager.enumerator(
                at: URL(fileURLWithPath: self.diskCachePath),
                includingPropertiesForKeys: Array(resourceKeys)
            )
            
            var totalSize: UInt64 = 0
            var deletingURLs: [URL] = []
            let expirationDate = Date().addingTimeInterval(-self.cacheTimeToLive)
            
            while let fileURL = fileEnumerator?.nextObject() as? URL {
                guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys),
                      let creationDate = resourceValues.creationDate,
                      let fileSize = resourceValues.totalFileAllocatedSize else {
                    continue
                }
                
                if creationDate < expirationDate {
                    deletingURLs.append(fileURL)
                    continue
                }
                
                totalSize += UInt64(fileSize)
            }
            
            if totalSize > self.maxDiskCacheSize {
                for fileURL in deletingURLs {
                    try? self.fileManager.removeItem(at: fileURL)
                }
            }
        }
    }
}
