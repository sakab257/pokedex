//
//  ContentView.swift
//  Pokedex
//
//  Created by Salim on 29/11/2025.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    init() {
        // =========================================================
        // 1. TAB BAR CONFIGURATION
        // =========================================================
        
        // Inactive icons color
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray.withAlphaComponent(0.6)
        
        // Appearance
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        
        // Pixelmix font for the tabs
        let pixelTabFont = UIFont(name: "Pixelmix", size: 10) ?? UIFont.systemFont(ofSize: 10)
        let tabAttributes: [NSAttributedString.Key: Any] = [.font: pixelTabFont]
        
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = tabAttributes
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = tabAttributes
        tabAppearance.inlineLayoutAppearance.normal.titleTextAttributes = tabAttributes
        tabAppearance.inlineLayoutAppearance.selected.titleTextAttributes = tabAttributes
        
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        
        
        // =========================================================
        // 2. NAV CONFIGURATION
        // =========================================================
        
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithDefaultBackground()
        
        // A. Font for the Bug Titles (Large Title)
        if let largeFont = UIFont(name: "Pixelmix", size: 48) {
            navAppearance.largeTitleTextAttributes = [
                .font: largeFont,
                .foregroundColor: UIColor.label
            ]
        }
        
        // B. Font for the Smaller Titles
        if let smallFont = UIFont(name: "Pixelmix", size: 32) {
            navAppearance.titleTextAttributes = [
                .font: smallFont,
                .foregroundColor: UIColor.label
            ]
        }
        
        // Apply the congif to all other states
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        
        UINavigationBar.appearance().tintColor = UIColor.label
    }
    
    var body: some View {
        TabView {
            PokemonListView()
                .tabItem {
                    Label("Pokedex", systemImage: "square.split.2x2")
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
        // Change the color of the active tab
        .tint(.red)
        .preferredColorScheme(nil)
    }
}

#Preview {
    ContentView()
}
