//
//  Theme.swift
//  Pokedex
//
//  Centralized theming system
//

import SwiftUI

struct AppTheme {
    // MARK: - Colors
    struct Colors {
        // Backgrounds
        static func background(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "#1A1A1A") : Color(hex: "#F5F5F5")
        }
        
        static func cardBackground(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "#2A2A2A") : .white
        }
        
        static func imageBackground(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "#3A3A3A") : Color(.systemGray6)
        }
        
        // Text
        static func primaryText(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? .white : .black
        }
        
        static func secondaryText(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color.white.opacity(0.7) : Color.black.opacity(0.7)
        }
        
        // Borders
        static let border = Color.black
    }
    
    // MARK: - Typography
    struct Typography {
        static let fontName = "Pixelmix"
        
        static func title(size: CGFloat = 20) -> Font {
            .custom(fontName, size: size)
        }
        
        static func body(size: CGFloat = 14) -> Font {
            .custom(fontName, size: size)
        }
        
        static func caption(size: CGFloat = 10) -> Font {
            .custom(fontName, size: size)
        }
        
        static func pokemonNumber(size: CGFloat = 12) -> Font {
            .custom(fontName, size: size)
        }
    }
    
    // MARK: - Layout
    struct Layout {
        static let pokemonImageSize: CGFloat = 70
        static let pokemonCellMinHeight: CGFloat = 120
        static let itemImageSize: CGFloat = 60
        static let borderWidth: CGFloat = 3
        static let itemBorderWidth: CGFloat = 2
        static let cornerRadius: CGFloat = 0 // For retro pixelated look
        static let gridSpacing: CGFloat = 0
    }
}
