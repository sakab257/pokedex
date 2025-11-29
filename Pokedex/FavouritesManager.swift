//
//  FavouritesManager.swift
//  Pokedex
//
//  Manages persistence of favourite Pokemon using UserDefaults
//

import Foundation
import SwiftUI
import Combine

class FavouritesManager: ObservableObject {
    static let shared = FavouritesManager()
    
    @Published var favourites: [Pokemon] = []
    
    private let key = "favourite_pokemon_list"
    
    private init() {
        loadFavourites()
    }
    
    func isFavourite(pokemon: Pokemon) -> Bool {
        favourites.contains { $0.pokemonId == pokemon.pokemonId }
    }
    
    func toggleFavourite(pokemon: Pokemon) {
        if isFavourite(pokemon: pokemon) {
            remove(pokemon: pokemon)
        } else {
            add(pokemon: pokemon)
        }
    }
    
    private func add(pokemon: Pokemon) {
        if !isFavourite(pokemon: pokemon) {
            favourites.insert(pokemon, at: 0)
            save()
        }
    }
    
    private func remove(pokemon: Pokemon) {
        favourites.removeAll { $0.pokemonId == pokemon.pokemonId }
        save()
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(favourites) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    // Changé de 'private' à 'func' simple pour être accessible depuis le ViewModel
    func loadFavourites() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Pokemon].self, from: data) {
            // Animation pour rendre le refresh plus fluide visuellement
            withAnimation {
                favourites = decoded
            }
        }
    }
}
