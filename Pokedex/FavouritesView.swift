//
//  FavouritesView.swift
//  Pokedex
//
//  Created by Salim on 29/11/2025.
//

import SwiftUI

struct FavouritesView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var backgroundColor: Color {
        colorScheme == .dark ? Color(hex: "#1A1A1A") : Color(hex: "#F5F5F5")
    }
    
    var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color that ignores safe area
                backgroundColor
                    .ignoresSafeArea()
                
                VStack {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                        .padding()
                    
                    Text("Favourites")
                        .font(.custom("Pixelmix", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                    
                    Text("Coming Soon...")
                        .font(.custom("Pixelmix", size: 12))
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
