//
//  Pokemon.swift
//  Pokedex
//
//  Created by Salim on 29/11/2025.
//

import Foundation
import SwiftUI

struct PokemonResponse: Codable {
    let results: [Pokemon]
}

struct Pokemon: Codable, Identifiable, Hashable {
    let name: String
    let url: String
    
    var id: String {
        return url
    }
    
    var pokemonId: Int? {
        // The URL looks like: https://pokeapi.co/api/v2/pokemon/1/
        let components = url.split(separator: "/")
        
        // Find "pokemon" then take the next element
        if let pokemonIndex = components.firstIndex(of: "pokemon"),
           pokemonIndex + 1 < components.count {
            return Int(components[pokemonIndex + 1])
        }
        return nil
    }
    
    var imageUrl: URL? {
        guard let id = pokemonId else { 
            return nil
        }
        let imageUrlString = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png"
        return URL(string: imageUrlString)
    }
    
    var backgroundColor: Color {
        guard let id = pokemonId else { return Color.gray }
        return PokemonColorMap.getColor(for: id)
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case url
    }
}

// Extension to create Color from hex string
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
