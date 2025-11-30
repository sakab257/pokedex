//
//  Item.swift
//  Pokedex
//
//  Created by Salim on 29/11/2025.
//

import Foundation

struct ItemResponse: Codable {
    let results: [ItemSummary]
}

struct ItemSummary: Codable, Identifiable {
    let name: String
    let url: String
    
    var id: String {
        return url
    }
    
    var itemId: Int? {
        let components = url.split(separator: "/")
        if let itemIndex = components.firstIndex(of: "item"),
           itemIndex + 1 < components.count {
            return Int(components[itemIndex + 1])
        }
        return nil
    }
    
    var imageUrl: URL? {
        // CORRECTION : On vérifie juste que l'ID existe, pas besoin de créer une variable 'id' inutilisée
        guard itemId != nil else { return nil }
        return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/\(name).png")
    }
}

struct ItemDetail: Codable {
    let id: Int
    let name: String
    let sprites: ItemSprites
    let effect_entries: [EffectEntry]
    
    struct ItemSprites: Codable {
        let `default`: String?
    }
    
    struct EffectEntry: Codable {
        let effect: String
        let language: Language
        
        struct Language: Codable {
            let name: String
        }
    }
    
    // Get English description
    var englishEffect: String {
        effect_entries.first(where: { $0.language.name == "en" })?.effect ?? "No description available."
    }
}
