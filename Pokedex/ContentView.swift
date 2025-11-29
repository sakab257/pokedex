//
//  ContentView.swift
//  Pokedex
//
//  Created by Salim on 29/11/2025.
//

import SwiftUI

// Main tab view container
struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        TabView {
            PokemonListView()
                .tabItem {
                    Label("Pokédex", systemImage: "list.bullet.rectangle.portrait")
                }
            
            ItemsView()
                .tabItem {
                    Label("Items", systemImage: "cube.box.fill")
                }
            
            FavouritesView()
                .tabItem {
                    Label("Favourites", systemImage: "heart.fill")
                }
        }
        .preferredColorScheme(nil) // Allow system to control
    }
}

// Pokemon list view (previously ContentView)
struct PokemonListView: View {
    // Instantiate our ViewModel
    @StateObject var viewModel = PokemonViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    // Grid configuration (3 columns with no spacing)
    let columns = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
    var backgroundColor: Color {
        colorScheme == .dark ? Color(hex: "#1A1A1A") : Color(hex: "#F5F5F5")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color that ignores safe area
                backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(viewModel.filteredPokemonList) { pokemon in
                            PokemonCell(pokemon: pokemon)
                        }
                    }
                }
            }
            .navigationTitle("Pokedex")
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
    @Environment(\.colorScheme) var colorScheme
    
    var borderColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
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
                            .foregroundColor(textColor.opacity(0.3))
                            .frame(width: 70, height: 70)
                    default:
                        ProgressView() // Loading spinner
                            .frame(width: 70, height: 70)
                    }
                }
                
                Text(pokemon.name.capitalized)
                    .font(.custom("Pixelmix", size: 12))
                    .fontWeight(.bold)
                    .foregroundColor(textColor)
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
                    .stroke(borderColor, lineWidth: 3)
            )
            
            // Pokemon number in top-right corner
            if let pokemonId = pokemon.pokemonId {
                Text("#\(pokemonId)")
                    .font(.custom("Pixelmix", size: 12))
                    .fontWeight(.bold)
                    .foregroundColor(textColor)
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
