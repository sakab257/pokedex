//
//  FavouritesViewModel.swift
//  Pokedex
//
//  ViewModel for managing the Favourites view state
//

import Foundation
import SwiftUI
import Combine

class FavouritesViewModel: ObservableObject {
    @Published var favourites: [Pokemon] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let manager = FavouritesManager.shared
    
    init() {
        manager.$favourites
            .assign(to: \.favourites, on: self)
            .store(in: &cancellables)
    }
    
    // Fonction appelée par le .refreshable
    func refresh() async {
        // On simule une petite attente réseau pour que l'utilisateur "sente" le refresh
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 secondes
        
        // On recharge les données depuis le disque
        await MainActor.run {
            manager.loadFavourites()
        }
    }
}
