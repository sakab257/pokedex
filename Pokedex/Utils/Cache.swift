//
//  Cache.swift
//  Pokedex
//
//  In-memory caching system
//

import Foundation

// CORRECTION : Ajout de 'async' au protocole pour supporter les Actors
protocol CacheProtocol {
    func get<T>(forKey key: String) async -> T?
    func set<T>(_ value: T, forKey key: String) async
    func remove(forKey key: String) async
    func clearAll() async
}

/// Thread-safe in-memory cache
actor InMemoryCache: CacheProtocol {
    static let shared = InMemoryCache()
    
    private var storage: [String: Any] = [:]
    
    private init() {}
    
    func get<T>(forKey key: String) -> T? {
        return storage[key] as? T
    }
    
    func set<T>(_ value: T, forKey key: String) {
        storage[key] = value
    }
    
    func remove(forKey key: String) {
        storage.removeValue(forKey: key)
    }
    
    func clearAll() {
        storage.removeAll()
    }
}

/// UserDefaults-backed cache for persistence across app launches
class PersistentCache: CacheProtocol {
    static let shared = PersistentCache()
    
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {}
    
    // Les fonctions doivent être marquées 'async' pour satisfaire le protocole,
    // même si UserDefaults est techniquement synchrone.
    func get<T>(forKey key: String) async -> T? {
        // For simple types
        if let value = userDefaults.object(forKey: key) as? T {
            return value
        }
        
        // For Codable types - use type constraint
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        
        // Only decode if T conforms to Decodable
        guard let decodableType = T.self as? any Decodable.Type else {
            return nil
        }
        
        return try? decoder.decode(decodableType, from: data) as? T
    }
    
    func set<T>(_ value: T, forKey key: String) async {
        // For simple types
        if value is String || value is Int || value is Double || value is Bool || value is Date {
            userDefaults.set(value, forKey: key)
            return
        }
        
        // For Codable types
        if let encodableValue = value as? Encodable {
            let data = try? encoder.encode(encodableValue)
            userDefaults.set(data, forKey: key)
        }
    }
    
    func remove(forKey key: String) async {
        userDefaults.removeObject(forKey: key)
    }
    
    func clearAll() async {
        if let bundleID = Bundle.main.bundleIdentifier {
            userDefaults.removePersistentDomain(forName: bundleID)
        }
    }
}
