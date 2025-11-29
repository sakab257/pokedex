//
//  ContentView.swift
//  Pokedex
//
//  Created by Salim on 29/11/2025.
//

import SwiftUI

struct ContentView: View {
    // Instantiate our ViewModel
    @StateObject var viewModel = PokemonViewModel()
    
    // Grid configuration (2 columns)
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.filteredPokemonList) { pokemon in
                        PokemonCell(pokemon: pokemon)
                    }
                }
                .padding()
            }
            .navigationTitle("Pokédex")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search for a Pokemon"
            )
        }
    }
}

// A subview to keep the code clean
struct PokemonCell: View {
    let pokemon: Pokemon
    
    var body: some View {
        VStack {
            // Asynchronous image loading
            AsyncImage(url: pokemon.imageUrl) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                case .failure:
                    Image(systemName: "photo") // Default image if error
                        .foregroundColor(.gray)
                default:
                    ProgressView() // Loading spinner
                }
            }
            
            Text(pokemon.name.capitalized)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    ContentView()
}
