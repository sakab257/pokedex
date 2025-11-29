//
//  FavouritesView.swift
//  Pokedex
//
//  Created by Salim on 29/11/2025.
//

import SwiftUI

struct FavouritesView: View {
    @StateObject var viewModel = FavouritesViewModel()
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
                
                if viewModel.favourites.isEmpty {
                    emptyStateView
                } else {
                    favouritesGridView
                }
            }
            .navigationTitle("Favourites")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var favouritesGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: AppTheme.Layout.gridSpacing) {
                ForEach(viewModel.favourites) { pokemon in
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
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.secondaryText(for: colorScheme).opacity(0.5))
            
            Text("No Favourites Yet")
                .font(AppTheme.Typography.title())
                .foregroundColor(AppTheme.Colors.primaryText(for: colorScheme))
            
            Text("Mark your favorite Pokemon with a heart to see them here!")
                .font(AppTheme.Typography.body())
                .foregroundColor(AppTheme.Colors.secondaryText(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

#Preview {
    FavouritesView()
}
