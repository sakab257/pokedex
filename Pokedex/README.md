# 📱 Pokédex App

A modern, retro-styled Pokédex application built with SwiftUI that displays Generation 1 Pokémon and items using the PokéAPI.

![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-blue.svg)

## ✨ Features

### ✅ Implemented
- [x] Browse all 151 Generation 1 Pokémon in a 3-column grid layout
- [x] Search Pokémon and items by name
- [x] View items with descriptions and sprites
- [x] Dark mode support
- [x] Retro pixel font design ("Pixelmix")
- [x] Custom color palette for each Pokémon (151 unique colors)
- [x] High-quality official artwork sprites
- [x] Tab-based navigation (Pokédex, Items, Favourites)
- [x] Async image loading with loading states
- [x] Special character removal in item descriptions

### 🚧 Next Steps
- [ ] Detailed Pokémon view with stats, abilities, and types
- [ ] Add Pokémon to favourites list
- [ ] Persist favourites with SwiftData
- [ ] Evolution chain visualization
- [ ] Filter Pokémon by type
- [ ] Sort options (by number, name, type)
- [ ] Pokémon abilities and moves database
- [ ] Type effectiveness chart
- [ ] Offline mode with caching

## 🏗 Architecture

**MVVM Pattern** with SwiftUI and Swift Concurrency

### Models
- **Pokemon.swift**: Pokémon data models, 151 custom colors, hex color extension
- **Item.swift**: Item data models with detailed effects

### ViewModels
- **PokemonViewModel.swift**: Fetches and filters Pokémon (async/await)
- **ItemViewModel.swift**: Manages items with lazy detail loading

### Views
- **ContentView.swift**: Main TabView with Pokédex grid
- **ItemsView.swift**: Items list with on-demand detail fetching
- **FavouritesView.swift**: Placeholder for favourites feature

## 🛠 Tech Stack

- **SwiftUI**: Declarative UI
- **Swift Concurrency**: async/await for networking
- **Combine**: ObservableObject and @Published
- **URLSession**: Native API calls
- **PokéAPI**: RESTful Pokémon data

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Installation
1. Clone the repository
2. Open in Xcode
3. Add "Pixelmix" font to project and Info.plist
4. Build and run

### Font Setup
Add to `Info.plist`:
```xml
<key>UIAppFonts</key>
<array>
    <string>Pixelmix.ttf</string>
</array>
```

## 🎨 Design

- **Retro aesthetic**: Pixel font, 3px borders, unique Pokémon colors
- **Dark mode**: Custom colors (`#1A1A1A` dark / `#F5F5F5` light backgrounds)
- **Performance**: LazyVGrid, on-demand loading, AsyncImage caching

## 📄 License

Educational purposes. Pokémon © Nintendo/Creatures Inc./GAME FREAK Inc.

## 🙏 Credits

- [PokéAPI](https://pokeapi.co/) - Free Pokémon API
- Pixelmix Font - Retro typography
- Nintendo/Game Freak - Original designs

---

**Created by Salim** • November 29, 2025

