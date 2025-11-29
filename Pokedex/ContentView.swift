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
    
    // Grid configuration (3 columns with no spacing)
    let columns = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(viewModel.filteredPokemonList) { pokemon in
                        PokemonCell(pokemon: pokemon)
                    }
                }
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
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 6) {
                // Asynchronous image loading
                AsyncImage(url: pokemon.imageUrl) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 70)
                    case .failure:
                        Image(systemName: "photo") // Default image if error
                            .font(.system(size: 30))
                            .foregroundColor(.black.opacity(0.3))
                            .frame(width: 70, height: 70)
                    default:
                        ProgressView() // Loading spinner
                            .frame(width: 70, height: 70)
                    }
                }
                
                Text(pokemon.name.capitalized)
                    .font(.custom("Pixelmix", size: 12))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, 2)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 2)
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(pokemon.backgroundColor)
            .overlay(
                Rectangle()
                    .stroke(.black, lineWidth: 3)
            )
            
            // Pokemon number in top-right corner
            if let pokemonId = pokemon.pokemonId {
                Text("#\(pokemonId)")
                    .font(.custom("Pixelmix", size: 12))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(5)
            }
        }
    }
}

// Helper to print available fonts (add this temporarily to debug)
struct FontDebugView: View {
    var body: some View {
        VStack {
            ForEach(UIFont.familyNames.sorted(), id: \.self) { family in
                let names = UIFont.fontNames(forFamilyName: family)
                Text("\(family): \(names.joined(separator: ", "))")
                    .font(.caption)
            }
        }
    }
}

#Preview {
    ContentView()
}
