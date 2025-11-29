//
//  PokemonViewModel.swift
//  Pokedex
//
//  Created by Salim on 29/11/2025.
//

import Foundation
import SwiftUI
import Combine

class PokemonViewModel: ObservableObject {
    // @Published notifies the view when data changes to refresh the screen
    @Published var pokemonList: [Pokemon] = []
    @Published var searchText: String = ""
    
    // Filtered list based on search
    var filteredPokemonList: [Pokemon] {
        if searchText.isEmpty {
            return pokemonList
        } else {
            return pokemonList.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    init() {
        Task {
            await fetchPokemon()
        }
    }
    
    @MainActor
    func fetchPokemon() async {
        // Fetch the first 151 Pokémon (Gen 1)
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=151") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(PokemonResponse.self, from: data)
            
            // With @MainActor, we're already on the main thread
            self.pokemonList = decodedResponse.results
            
        } catch {
            fatalError("Error: \(error)")
        }
    }
}
