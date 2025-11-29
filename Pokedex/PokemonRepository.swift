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
    func getEvolutionChain(for pokemonId: Int) async throws -> [Pokemon]
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
        static func pokemonDetail(_ id: Int) -> String {
            return "pokemon_detail_\(id)"
        }
        static func evolution(_ id: Int) -> String {
            return "pokemon_evolution_\(id)"
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
        if !forceRefresh {
            if let cachedPokemon = await getCachedPokemon(), await isCacheExpired() {
                return cachedPokemon
            }
        }
        let pokemon = try await service.fetchPokemon(limit: limit)
        await cachePokemon(pokemon)
        return pokemon
    }
    
    func getPokemonDetail(id: Int) async throws -> PokemonDetail {
        if let cachedDetail: PokemonDetail = await cache.get(forKey: CacheKey.pokemonDetail(id)) {
            return cachedDetail
        }
        let detail = try await service.fetchPokemonDetail(id: id)
        await cache.set(detail, forKey: CacheKey.pokemonDetail(id))
        return detail
    }
    
    // Récupération des évolutions
    func getEvolutionChain(for pokemonId: Int) async throws -> [Pokemon] {
        // Cache check
        if let cachedEvolutions: [Pokemon] = await cache.get(forKey: CacheKey.evolution(pokemonId)) {
            return cachedEvolutions
        }
        
        // 1. Get Species
        let species = try await service.fetchPokemonSpecies(id: pokemonId)
        
        // 2. Get Chain
        let chainResponse = try await service.fetchEvolutionChain(url: species.evolutionChain.url)
        
        // 3. Aplatir l'arbre en liste
        var evolutions: [Pokemon] = []
        
        func traverse(link: ChainLink) {
            if let id = link.species.id {
                // IMPORTANT: On reconstruit une URL de type "pokemon" et pas "pokemon-species"
                // pour que le modèle Pokemon puisse générer correctement l'URL de l'image.
                let properUrl = "https://pokeapi.co/api/v2/pokemon/\(id)/"
                
                let pokemon = Pokemon(
                    name: link.species.name,
                    url: properUrl
                )
                evolutions.append(pokemon)
            }
            
            for nextLink in link.evolvesTo {
                traverse(link: nextLink)
            }
        }
        
        traverse(link: chainResponse.chain)
        
        // Cache result
        await cache.set(evolutions, forKey: CacheKey.evolution(pokemonId))
        
        return evolutions
    }
    
    func clearCache() {
        Task {
            await cache.remove(forKey: CacheKey.pokemonList)
            await cache.remove(forKey: CacheKey.lastFetchTime)
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
