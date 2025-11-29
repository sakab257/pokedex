//
//  ItemRepository.swift
//  Pokedex
//
//  Repository pattern for Item data management with caching
//

import Foundation

protocol ItemRepositoryProtocol {
    func getItems(limit: Int, forceRefresh: Bool) async throws -> [ItemSummary]
    func getItemDetail(id: Int) async throws -> ItemDetail
    func clearCache()
}

class ItemRepository: ItemRepositoryProtocol {
    // MARK: - Dependencies
    private let service: ItemServiceProtocol
    private let cache: InMemoryCache
    
    // MARK: - Cache Keys
    private enum CacheKey {
        static let itemList = "item_list"
        static let lastFetchTime = "item_last_fetch"
        static func itemDetail(_ id: Int) -> String {
            return "item_detail_\(id)"
        }
    }
    
    // MARK: - Configuration
    private let cacheExpiration: TimeInterval = 3600 // 1 hour
    
    // MARK: - Initialization
    init(service: ItemServiceProtocol = ItemService(),
         cache: InMemoryCache = .shared) {
        self.service = service
        self.cache = cache
    }
    
    // MARK: - Methods
    func getItems(limit: Int = 200, forceRefresh: Bool = false) async throws -> [ItemSummary] {
        // Check if we should use cache
        if !forceRefresh {
            if let cachedItems = await getCachedItems(), await isCacheExpired() {
                return cachedItems
            }
        }
        
        // Fetch from network
        let items = try await service.fetchItems(limit: limit)
        
        // Update cache
        await cacheItems(items)
        
        return items
    }
    
    func getItemDetail(id: Int) async throws -> ItemDetail {
        // Check cache first
        if let cachedDetail: ItemDetail = await cache.get(forKey: CacheKey.itemDetail(id)) {
            return cachedDetail
        }
        
        // Fetch from network
        let detail = try await service.fetchItemDetail(id: id)
        
        // Cache it
        await cache.set(detail, forKey: CacheKey.itemDetail(id))
        
        return detail
    }
    
    func clearCache() {
        Task {
            await cache.remove(forKey: CacheKey.itemList)
            await cache.remove(forKey: CacheKey.lastFetchTime)
        }
    }
    
    // MARK: - Private Helper Methods
    private func getCachedItems() async -> [ItemSummary]? {
        return await cache.get(forKey: CacheKey.itemList)
    }
    
    private func cacheItems(_ items: [ItemSummary]) async {
        await cache.set(items, forKey: CacheKey.itemList)
        await cache.set(Date(), forKey: CacheKey.lastFetchTime)
    }
    
    private func isCacheExpired() async -> Bool {
        guard let lastFetch: Date = await cache.get(forKey: CacheKey.lastFetchTime) else {
            return true
        }
        return Date().timeIntervalSince(lastFetch) > cacheExpiration
    }
}
