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
