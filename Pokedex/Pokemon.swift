//
//  Pokemon.swift
//  Pokedex
//
//  Created by Salim on 29/11/2025.
//

import Foundation

// Structure pour la liste globale
struct PokemonResponse: Codable {
    let results: [Pokemon]
}

// Structure d'un Pokémon individuel
struct Pokemon: Codable, Identifiable {
    let name: String
    let url: String
    
    // Un ID unique pour SwiftUI basé sur l'URL
    var id: String {
        return url
    }
    
    // Nous allons extraire l'ID du Pokémon depuis l'URL pour récupérer son image plus tard
    var pokemonId: Int? {
        // L'URL ressemble à : https://pokeapi.co/api/v2/pokemon/1/
        // On divise l'URL et on récupère le dernier élément non vide
        let components = url.split(separator: "/")
        // On cherche "pokemon" puis on prend l'élément suivant
        if let pokemonIndex = components.firstIndex(of: "pokemon"),
           pokemonIndex + 1 < components.count {
            return Int(components[pokemonIndex + 1])
        }
        return nil
    }
    
    // URL de l'image officielle (Haute qualité)
    var imageUrl: URL? {
        guard let id = pokemonId else { 
            print("Cannot get the ID for: \(name), URL: \(url)")
            return nil
        }
        let imageUrlString = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png"
        return URL(string: imageUrlString)
    }
    
    // Pour décoder seulement name et url depuis le JSON
    enum CodingKeys: String, CodingKey {
        case name
        case url
    }
}
