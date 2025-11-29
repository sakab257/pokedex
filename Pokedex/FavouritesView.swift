//
//  FavouritesView.swift
//  Pokedex
//
//  Created by Salim on 29/11/2025.
//

import SwiftUI

struct FavouritesView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background(for: colorScheme)
                    .ignoresSafeArea()
                
                VStack {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                        .padding()
                    
                    Text("Favourites")
                        .font(AppTheme.Typography.title())
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.Colors.primaryText(for: colorScheme))
                    
                    Text("Coming Soon...")
                        .font(AppTheme.Typography.caption(size: 12))
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
            }
            .navigationTitle("Favourites")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    FavouritesView()
}

