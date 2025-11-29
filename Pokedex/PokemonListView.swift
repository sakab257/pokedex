//
//  PokemonListView.swift
//  Pokedex
//
//  Created by Salim on 29/11/2025.
//

import SwiftUI

struct PokemonListView: View {
    @StateObject var viewModel = PokemonViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.Layout.gridSpacing),
        GridItem(.flexible(), spacing: AppTheme.Layout.gridSpacing),
        GridItem(.flexible(), spacing: AppTheme.Layout.gridSpacing)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background(for: colorScheme)
                    .ignoresSafeArea()
                
                contentView
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
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .idle:
            EmptyView()
            
        case .loading where viewModel.pokemonList.isEmpty:
            loadingView
            
        case .loading, .loaded:
            if viewModel.filteredPokemonList.isEmpty && !viewModel.searchText.isEmpty {
                emptySearchView
            } else {
                pokemonGridView
            }
            
        case .error(let message):
            errorView(message: message)
        }
    }
    
    private var pokemonGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: AppTheme.Layout.gridSpacing) {
                ForEach(viewModel.filteredPokemonList) { pokemon in
                    NavigationLink(destination: PokemonDetailView(pokemon: pokemon)) {
                        PokemonCell(pokemon: pokemon)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading Pokemon...")
                .font(AppTheme.Typography.body())
                .foregroundColor(AppTheme.Colors.secondaryText(for: colorScheme))
        }
    }
    
    private var emptySearchView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.Colors.secondaryText(for: colorScheme))
            
            Text("No Pokemon Found")
                .font(AppTheme.Typography.title(size: 16))
                .foregroundColor(AppTheme.Colors.primaryText(for: colorScheme))
            
            Text("Try a different search term")
                .font(AppTheme.Typography.caption())
                .foregroundColor(AppTheme.Colors.secondaryText(for: colorScheme))
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Oops!")
                .font(AppTheme.Typography.title())
                .foregroundColor(AppTheme.Colors.primaryText(for: colorScheme))
            
            Text(message)
                .font(AppTheme.Typography.body())
                .foregroundColor(AppTheme.Colors.secondaryText(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                Task {
                    await viewModel.retry()
                }
            } label: {
                Text("Retry")
                    .font(AppTheme.Typography.body())
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .overlay(
                        Rectangle()
                            .stroke(AppTheme.Colors.border, lineWidth: 2)
                    )
            }
            .disabled(viewModel.state.isLoading)
        }
    }
}

struct PokemonCell: View {
    let pokemon: Pokemon
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        // ZStack global pour la cellule
        ZStack {
            // 1. COUCHE DE FOND (Couleur + Watermark)
            // C'est ici que la magie opère pour éviter l'effet "fade" ou "trop chargé"
            ZStack(alignment: .bottomTrailing) {
                // A. La couleur de base
                pokemon.backgroundColor
                
                // B. Le Watermark Pokéball
                Image("Frame 1")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.white) // Toujours blanc pour éclaircir la couleur
                    .opacity(0.3) // Assez transparent pour être subtil
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100) // Grande taille
                    .rotationEffect(.degrees(90)) // Rotation dynamique
                    .offset(x: 30, y: 15) // On la pousse vers le coin pour la couper
            }
            .clipped() // Important : coupe ce qui dépasse de la cellule
            
            // 2. COUCHE DE CONTENU (Sprite + Texte + Numéro)
            VStack(spacing: 0) {
                Spacer() // Pousse le contenu vers le centre/bas
                
                // Sprite Pokémon avec ombre
                AsyncImage(url: pokemon.imageUrl) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(
                                width: AppTheme.Layout.pokemonImageSize,
                                height: AppTheme.Layout.pokemonImageSize
                            )
                            .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 4) // Ombre portée qui détache le Pokemon du fond
                    case .failure:
                        Image(systemName: "photo")
                            .font(.system(size: 30))
                            .foregroundColor(.black.opacity(0.3))
                            .frame(
                                width: AppTheme.Layout.pokemonImageSize,
                                height: AppTheme.Layout.pokemonImageSize
                            )
                    default:
                        ProgressView()
                            .frame(
                                width: AppTheme.Layout.pokemonImageSize,
                                height: AppTheme.Layout.pokemonImageSize
                            )
                    }
                }
                .padding(.bottom, 4)
                
                // Nom du Pokémon sur fond semi-transparent pour lisibilité
                Text(pokemon.name.capitalized)
                    .font(AppTheme.Typography.caption(size: 12))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.5)) // Petit fond pilule subtil sous le texte
                    )
                    .padding(.bottom, 8)
            }
            
            // 3. Numéro en haut à droite (au-dessus de tout)
            VStack {
                HStack {
                    Spacer()
                    if let pokemonId = pokemon.pokemonId {
                        Text("#\(pokemonId)")
                            .font(AppTheme.Typography.pokemonNumber(size: 10))
                            .fontWeight(.heavy)
                            .foregroundColor(.black.opacity(0.5))
                            .padding(6)
                    }
                }
                Spacer()
            }
        }
        .frame(height: AppTheme.Layout.pokemonCellMinHeight) // Hauteur fixe pour régularité
        .overlay(
            Rectangle()
                .stroke(AppTheme.Colors.border, lineWidth: AppTheme.Layout.borderWidth)
        )
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
    PokemonListView()
}
