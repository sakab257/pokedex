//
//  PokemonDetail.swift
//  Pokedex
//
//  Detailed Pokemon model
//

import Foundation

struct PokemonDetail: Codable, Identifiable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let types: [PokemonTypeSlot]
    let stats: [PokemonStat]
    let abilities: [PokemonAbility]
    let sprites: PokemonSprites
    
    struct PokemonTypeSlot: Codable {
        let slot: Int
        let type: PokemonType
        
        struct PokemonType: Codable {
            let name: String
        }
    }
    
    struct PokemonStat: Codable, Identifiable {
        let baseStat: Int
        let effort: Int
        let stat: Stat
        
        var id: String { stat.name }
        
        struct Stat: Codable {
            let name: String
        }
        
        enum CodingKeys: String, CodingKey {
            case baseStat = "base_stat"
            case effort
            case stat
        }
    }
    
    struct PokemonAbility: Codable, Identifiable {
        let isHidden: Bool
        let slot: Int
        let ability: Ability
        
        var id: String { ability.name }
        
        struct Ability: Codable {
            let name: String
        }
        
        enum CodingKeys: String, CodingKey {
            case isHidden = "is_hidden"
            case slot
            case ability
        }
    }
    
    struct PokemonSprites: Codable {
        let frontDefault: String?
        let frontShiny: String?
        let other: OtherSprites?
        
        struct OtherSprites: Codable {
            let officialArtwork: OfficialArtwork?
            
            struct OfficialArtwork: Codable {
                let frontDefault: String?
                
                enum CodingKeys: String, CodingKey {
                    case frontDefault = "front_default"
                }
            }
            
            enum CodingKeys: String, CodingKey {
                case officialArtwork = "official-artwork"
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case frontDefault = "front_default"
            case frontShiny = "front_shiny"
            case other
        }
    }
    
    // Helper computed properties
    var imageUrl: URL? {
        if let artwork = sprites.other?.officialArtwork?.frontDefault {
            return URL(string: artwork)
        }
        return nil
    }
    
    var heightInMeters: Double {
        Double(height) / 10.0 // API returns in decimeters
    }
    
    var weightInKg: Double {
        Double(weight) / 10.0 // API returns in hectograms
    }
    
    var typeNames: [String] {
        types.sorted(by: { $0.slot < $1.slot }).map { $0.type.name }
    }
    
    var primaryType: String? {
        typeNames.first
    }
}
