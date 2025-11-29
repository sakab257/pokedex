//
//  PokemonRepository.swift
//  Pokedex
//
//  Repository pattern for Pokemon data management with caching
//

import Foundation

protocol PokemonRepositoryProtocol {
    func getPokemon(limit: Int, forceRefresh: Bool) async throws -> [Pokemon]
    func getPokemonDetail(id: Int) async throws -> PokemonDetail
    func clearCache()
}

class PokemonRepository: PokemonRepositoryProtocol {
    // MARK: - Dependencies
    private let service: PokemonServiceProtocol
    private let cache: InMemoryCache
    
    // MARK: - Cache Keys
    private enum CacheKey {
        static let pokemonList = "pokemon_list"
        static let lastFetchTime = "pokemon_last_fetch"
        // Ajout de la clé pour le cache des détails
        static func pokemonDetail(_ id: Int) -> String {
            return "pokemon_detail_\(id)"
        }
    }
    
    // MARK: - Configuration
    private let cacheExpiration: TimeInterval = 3600 // 1 hour
    
    // MARK: - Initialization
    init(service: PokemonServiceProtocol = PokemonService(),
         cache: InMemoryCache = .shared) {
        self.service = service
        self.cache = cache
    }
    
    // MARK: - Methods
    func getPokemon(limit: Int = 151, forceRefresh: Bool = false) async throws -> [Pokemon] {
        // Check if we should use cache
        if !forceRefresh {
            if let cachedPokemon = await getCachedPokemon(), await isCacheExpired() {
                return cachedPokemon
            }
        }
        
        // Fetch from network
        let pokemon = try await service.fetchPokemon(limit: limit)
        
        // Update cache
        await cachePokemon(pokemon)
        
        return pokemon
    }
    
    // C'était la méthode manquante qui causait l'erreur
    func getPokemonDetail(id: Int) async throws -> PokemonDetail {
        // Check cache first
        if let cachedDetail: PokemonDetail = await cache.get(forKey: CacheKey.pokemonDetail(id)) {
            return cachedDetail
        }
        
        // Fetch from network
        let detail = try await service.fetchPokemonDetail(id: id)
        
        // Cache it
        await cache.set(detail, forKey: CacheKey.pokemonDetail(id))
        
        return detail
    }
    
    func clearCache() {
        Task {
            await cache.remove(forKey: CacheKey.pokemonList)
            await cache.remove(forKey: CacheKey.lastFetchTime)
            // Note: On ne vide pas forcément le cache des détails ici pour garder l'expérience fluide,
            // ou on pourrait tout vider avec cache.clearAll() si nécessaire.
        }
    }
    
    // MARK: - Private Helper Methods
    private func getCachedPokemon() async -> [Pokemon]? {
        return await cache.get(forKey: CacheKey.pokemonList)
    }
    
    private func cachePokemon(_ pokemon: [Pokemon]) async {
        await cache.set(pokemon, forKey: CacheKey.pokemonList)
        await cache.set(Date(), forKey: CacheKey.lastFetchTime)
    }
    
    private func isCacheExpired() async -> Bool {
        guard let lastFetch: Date = await cache.get(forKey: CacheKey.lastFetchTime) else {
            return true
        }
        return Date().timeIntervalSince(lastFetch) > cacheExpiration
    }
}
