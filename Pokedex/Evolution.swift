//
//  Evolution.swift
//  Pokedex
//
//  Models for parsing Evolution Chains
//

import Foundation

struct PokemonSpecies: Codable {
    let evolutionChain: APIReference
    
    enum CodingKeys: String, CodingKey {
        case evolutionChain = "evolution_chain"
    }
}

struct APIReference: Codable {
    let url: String
}

struct EvolutionChainResponse: Codable {
    let chain: ChainLink
}

struct ChainLink: Codable {
    let species: NamedAPIResource
    let evolvesTo: [ChainLink]
    
    enum CodingKeys: String, CodingKey {
        case species
        case evolvesTo = "evolves_to"
    }
}

struct NamedAPIResource: Codable {
    let name: String
    let url: String
    
    // Helper to extract ID from URL to build image links
    var id: Int? {
        // url format: .../species/1/
        let components = url.split(separator: "/")
        if let last = components.last {
            return Int(last)
        }
        return nil
    }
}
