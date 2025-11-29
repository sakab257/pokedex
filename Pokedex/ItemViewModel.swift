//
//  ItemViewModel.swift
//  Pokedex
//
//  Created by Salim on 29/11/2025.
//

import Foundation
import SwiftUI
import Combine

class ItemViewModel: ObservableObject {
    @Published var items: [ItemSummary] = []
    @Published var itemDetails: [Int: ItemDetail] = [:]
    @Published var searchText: String = ""
    
    // Filtered list based on search
    var filteredItems: [ItemSummary] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    init() {
        Task {
            await fetchItems()
        }
    }
    
    @MainActor
    func fetchItems() async {
        // Fetch the first 200 items
        guard let url = URL(string: "https://pokeapi.co/api/v2/item?limit=200") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(ItemResponse.self, from: data)
            self.items = decodedResponse.results
            
            // Fetch details for each item
            await fetchItemDetails()
        } catch {
            print("Error fetching items: \(error)")
        }
    }
    
    @MainActor
    private func fetchItemDetails() async {
        // Fetch details for visible items (first 50 to avoid rate limiting)
        for item in items.prefix(50) {
            guard let id = item.itemId else { continue }
            
            // Skip if already loaded
            if itemDetails[id] != nil { continue }
            
            do {
                let detailUrl = URL(string: "https://pokeapi.co/api/v2/item/\(id)/")!
                let (data, _) = try await URLSession.shared.data(from: detailUrl)
                let detail = try JSONDecoder().decode(ItemDetail.self, from: data)
                itemDetails[id] = detail
            } catch {
                print("Error fetching detail for item \(id): \(error)")
            }
        }
    }
    
    // Fetch detail for a specific item on demand
    @MainActor
    func fetchItemDetail(for item: ItemSummary) async {
        guard let id = item.itemId else { return }
        
        // Skip if already loaded
        if itemDetails[id] != nil { return }
        
        do {
            let detailUrl = URL(string: "https://pokeapi.co/api/v2/item/\(id)/")!
            let (data, _) = try await URLSession.shared.data(from: detailUrl)
            let detail = try JSONDecoder().decode(ItemDetail.self, from: data)
            itemDetails[id] = detail
        } catch {
            print("Error fetching detail for item \(id): \(error)")
        }
    }
}
