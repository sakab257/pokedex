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
    // @Published notifie la vue quand les données changent pour rafraîchir l'écran
    @Published var pokemonList: [Pokemon] = []
    @Published var searchText: String = ""
    
    // Liste filtrée basée sur la recherche
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
        // On récupère les 151 premiers Pokémon (Gen 1)
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=151") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(PokemonResponse.self, from: data)
            
            // Avec @MainActor, nous sommes déjà sur le thread principal
            self.pokemonList = decodedResponse.results
            
        } catch {
            print("Error: \(error)")
        }
    }
}
