//
//  PokemonViewModel.swift
//  Pokedex
//
//  Created by Salim on 29/11/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class PokemonViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var pokemonList: [Pokemon] = []
    @Published var searchText: String = ""
    @Published var state: LoadingState = .idle
    
    // MARK: - State
    enum LoadingState: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
        
        var isLoading: Bool {
            if case .loading = self { return true }
            return false
        }
    }
    
    // MARK: - Computed Properties
    var filteredPokemonList: [Pokemon] {
        if searchText.isEmpty {
            return pokemonList
        } else {
            return pokemonList.filter { 
                $0.name.lowercased().contains(searchText.lowercased()) 
            }
        }
    }
    
    // MARK: - Dependencies
    private let repository: PokemonRepositoryProtocol
    
    // MARK: - Initialization
    init(repository: PokemonRepositoryProtocol = PokemonRepository()) {
        self.repository = repository
        
        Task {
            await fetchPokemon()
        }
    }
    
    // MARK: - Methods
    func fetchPokemon(forceRefresh: Bool = false) async {
        guard state != .loading else { return }
        
        state = .loading
        
        do {
            let pokemon = try await repository.getPokemon(limit: 151, forceRefresh: forceRefresh)
            pokemonList = pokemon
            state = .loaded
        } catch let error as NetworkError {
            state = .error(error.localizedDescription)
        } catch {
            state = .error("An unexpected error occurred. Please try again.")
        }
    }
    
    func retry() async {
        await fetchPokemon(forceRefresh: true)
    }
    
    func refresh() async {
        await fetchPokemon(forceRefresh: true)
    }
}
