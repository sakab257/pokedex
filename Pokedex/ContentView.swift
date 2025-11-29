//
//  ContentView.swift
//  Pokedex
//
//  Created by Salim on 29/11/2025.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    // To personnalize unactive tabs
    init() {
        // To change inactive color icons
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray.withAlphaComponent(0.6)
        
        // To make the bar translucid
         let appearance = UITabBarAppearance()
         appearance.configureWithOpaqueBackground()
         UITabBar.appearance().standardAppearance = appearance
         UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView {
            PokemonListView()
                .tabItem {
                    Label("Pokédex", systemImage: "square.split.2x2")
                }
            
            ItemsView()
                .tabItem {
                    Label("Items", systemImage: "backpack.fill")
                }
            
            FavouritesView()
                .tabItem {
                    Label("Favourites", systemImage: "heart.fill")
                }
        }
        // Change the active state
        .tint(.red)
        .preferredColorScheme(nil)
    }
}

#Preview {
    ContentView()
}
