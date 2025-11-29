//
//  Item.swift
//  Pokedex
//
//  Created by Salim on 29/11/2025.
//

import Foundation

// Structure for the item list response
struct ItemResponse: Codable {
    let results: [ItemSummary]
}

// Summary of an item from the list endpoint
struct ItemSummary: Codable, Identifiable {
    let name: String
    let url: String
    
    var id: String {
        return url
    }
    
    // Extract item ID from URL
    var itemId: Int? {
        let components = url.split(separator: "/")
        if let itemIndex = components.firstIndex(of: "item"),
           itemIndex + 1 < components.count {
            return Int(components[itemIndex + 1])
        }
        return nil
    }
    
    // Image URL for the item
    var imageUrl: URL? {
        guard let id = itemId else { return nil }
        return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/\(name).png")
    }
}

// Detailed item information
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
