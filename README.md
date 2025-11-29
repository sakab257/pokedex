📱 Pokédex App

A modern, retro-styled Pokédex application built with SwiftUI that displays Generation 1 Pokémon and items using the PokéAPI.

✨ Features

✅ Implemented

[x] Browse all 151 Generation 1 Pokémon in a 3-column grid layout

[x] Search Pokémon and items by name

[x] Detailed View with:

Official artwork sprites with shadow effects

Dynamic background colors based on Pokémon type

Animated base stats bars

Type badges and physical stats (Weight/Height)

Evolution Chain visualization with navigation

[x] Favourites System:

Add/Remove Pokémon to favourites

Persistent storage using UserDefaults

Dedicated Favourites tab with "pull-to-refresh"

[x] Items Tab: Browse 200+ items with descriptions and sprites

[x] UI/UX:

Retro pixel font design ("Pixelmix") globally applied (Titles, Tabs, Body)

Custom color palette for each Pokémon (151 unique colors)

Dark mode support

"Glassmorphism" data cards and watermark backgrounds

[x] Performance:

Custom CachedImage for persistent image caching across tabs

Async/await concurrency

Lazy loading for lists and grids

🚧 Next Steps

[ ] Filter Pokémon by type

[ ] Sort options (by number, name, type)

[ ] Pokémon abilities and moves database

[ ] Type effectiveness chart


🏗 Architecture

MVVM Pattern with SwiftUI and Swift Concurrency

Models

Pokemon.swift: Pokémon data models, 151 custom colors, hex color extension

Item.swift: Item data models with detailed effects

Evolution.swift: Recursive models for parsing evolution chains

ViewModels

PokemonViewModel.swift: Fetches and filters Pokémon list

PokemonDetailViewModel.swift: Manages detailed data and evolution chains

ItemViewModel.swift: Manages items with lazy detail loading

FavouritesViewModel.swift: Manages the favourites list display

Managers & Services

PokemonService.swift & ItemService.swift: API networking layer

PokemonRepository.swift: Data coordination and caching logic

FavouritesManager.swift: Singleton managing persistence of favourite Pokémon

CachedImage.swift: Custom image loader with NSCache for optimal performance

Views

ContentView.swift: Main TabView configuration with custom appearance

PokemonListView.swift: Main grid display

PokemonDetailView.swift: Rich detail view with stats and evolutions

ItemsView.swift & ItemDetailView.swift: Item browsing

FavouritesView.swift: List of saved Pokémon

🛠 Tech Stack

SwiftUI: Declarative UI

Swift Concurrency: async/await for networking

Combine: ObservableObject, @Published, and reactive updates

UserDefaults: Simple data persistence

PokéAPI: RESTful Pokémon data source

🚀 Getting Started

Prerequisites

Xcode 15.0+

iOS 17.0+

Swift 5.9+

Installation

Clone the repository

Open in Xcode

Add "Pixelmix" font to project and Info.plist

Build and run

Font Setup

Ensure Info.plist contains:

<key>UIAppFonts</key>
<array>
    <string>pixelmix.ttf</string>
</array>


🎨 Design

Retro aesthetic: Pixel font, 3px borders, unique Pokémon colors

Visuals: Watermark backgrounds, animated progress bars, floating effects for items

Dark mode: Fully supported with custom adaptative colors

📄 License

Educational purposes. Pokémon © Nintendo/Creatures Inc./GAME FREAK Inc.

🙏 Credits

PokéAPI - Free Pokémon API

Pixelmix Font - Retro typography

Nintendo/Game Freak - Original designs

Created by Salim • November 2025
