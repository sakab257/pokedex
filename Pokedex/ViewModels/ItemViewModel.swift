//
//  ItemViewModel.swift
//  Pokedex
//
//  Created by Salim on 29/11/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ItemViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var items: [ItemSummary] = []
    @Published var itemDetails: [Int: ItemDetail] = [:]
    @Published var searchText: String = ""
    @Published var state: LoadingState = .idle
    
    // MARK: - State
    enum LoadingState: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
        
        var isLoading: Bool {
            if case .loading = self { return true }
            return false
        }
    }
    
    // MARK: - Computed Properties
    var filteredItems: [ItemSummary] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { 
                $0.name.lowercased().contains(searchText.lowercased()) 
            }
        }
    }
    
    // MARK: - Dependencies
    private let repository: ItemRepositoryProtocol
    
    // MARK: - Initialization
    init(repository: ItemRepositoryProtocol = ItemRepository()) {
        self.repository = repository
        
        Task {
            await fetchItems()
        }
    }
    
    // MARK: - Methods
    func fetchItems(forceRefresh: Bool = false) async {
        guard state != .loading else { return }
        
        state = .loading
        
        do {
            let fetchedItems = try await repository.getItems(limit: 200, forceRefresh: forceRefresh)
            items = fetchedItems
            state = .loaded
        } catch let error as NetworkError {
            state = .error(error.localizedDescription)
        } catch {
            state = .error("An unexpected error occurred. Please try again.")
        }
    }
    
    func fetchItemDetail(for item: ItemSummary) async {
        guard let id = item.itemId else { return }
        
        // Skip if already loaded
        if itemDetails[id] != nil { return }
        
        do {
            let detail = try await repository.getItemDetail(id: id)
            itemDetails[id] = detail
        } catch {
            // Silently fail for individual item details to not disrupt the list
            print("Error fetching detail for item \(id): \(error.localizedDescription)")
        }
    }
    
    func retry() async {
        await fetchItems(forceRefresh: true)
    }
    
    func refresh() async {
        await fetchItems(forceRefresh: true)
    }
}
