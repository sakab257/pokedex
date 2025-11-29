//
//  PokemonCell.swift
//  Pokedex
//
//  Reusable component for displaying a Pokemon in a grid
//

import SwiftUI

struct PokemonCell: View {
    let pokemon: Pokemon
    
    var body: some View {
        // ZStack global pour la cellule
        ZStack {
            // 1. COUCHE DE FOND (Couleur + Watermark)
            ZStack(alignment: .bottomTrailing) {
                // A. La couleur de base
                pokemon.backgroundColor
                
                // B. Le Watermark Pokéball
                Image("Frame 1")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .opacity(0.3)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(90))
                    .offset(x: 30, y: 15)
            }
            .clipped()
            
            // 2. COUCHE DE CONTENU (Sprite + Texte + Numéro)
            VStack(spacing: 0) {
                Spacer()
                
                // --- REMPLACEMENT ICI : CachedImage au lieu de AsyncImage ---
                CachedImage(url: pokemon.imageUrl) { image in
                    // CAS SUCCÈS : Image chargée
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: AppTheme.Layout.pokemonImageSize,
                            height: AppTheme.Layout.pokemonImageSize
                        )
                        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 4)
                } placeholder: {
                    // CAS CHARGEMENT OU ERREUR
                    ZStack {
                        // On garde la taille pour éviter que la cellule saute
                        Color.clear
                            .frame(
                                width: AppTheme.Layout.pokemonImageSize,
                                height: AppTheme.Layout.pokemonImageSize
                            )
                        
                        // Petit indicateur discret
                        ProgressView()
                            .scaleEffect(0.5)
                            .tint(.black.opacity(0.5))
                    }
                }
                .padding(.bottom, 4)
                
                // Nom du Pokémon
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
                            .fill(.white.opacity(0.5))
                    )
                    .padding(.bottom, 8)
            }
            
            // 3. Numéro en haut à droite
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
        .frame(height: AppTheme.Layout.pokemonCellMinHeight)
        .overlay(
            Rectangle()
                .stroke(AppTheme.Colors.border, lineWidth: AppTheme.Layout.borderWidth)
        )
    }
}
