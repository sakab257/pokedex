//
//  ItemsView.swift
//  Pokedex
//
//  Created by Salim on 29/11/2025.
//

import SwiftUI

struct ItemsView: View {
    @StateObject var viewModel = ItemViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background(for: colorScheme)
                    .ignoresSafeArea()
                
                contentView
            }
            .navigationTitle("Items")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search for an Item"
            )
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .idle:
            EmptyView()
            
        case .loading where viewModel.items.isEmpty:
            loadingView
            
        case .loading, .loaded:
            if viewModel.filteredItems.isEmpty && !viewModel.searchText.isEmpty {
                emptySearchView
            } else {
                itemListView
            }
            
        case .error(let message):
            errorView(message: message)
        }
    }
    
    private var itemListView: some View {
        List(viewModel.filteredItems) { item in
            ZStack {
                // Navigation Link invisible mais fonctionnel
                NavigationLink(destination: ItemDetailView(item: item)) {
                    EmptyView()
                }
                .opacity(0)
                
                // Contenu visible
                ItemRow(item: item, viewModel: viewModel)
            }
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading Items...")
                .font(AppTheme.Typography.body())
                .foregroundColor(AppTheme.Colors.secondaryText(for: colorScheme))
        }
    }
    
    private var emptySearchView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.Colors.secondaryText(for: colorScheme))
            
            Text("No Items Found")
                .font(AppTheme.Typography.title(size: 16))
                .foregroundColor(AppTheme.Colors.primaryText(for: colorScheme))
            
            Text("Try a different search term")
                .font(AppTheme.Typography.caption())
                .foregroundColor(AppTheme.Colors.secondaryText(for: colorScheme))
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Oops!")
                .font(AppTheme.Typography.title())
                .foregroundColor(AppTheme.Colors.primaryText(for: colorScheme))
            
            Text(message)
                .font(AppTheme.Typography.body())
                .foregroundColor(AppTheme.Colors.secondaryText(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                Task {
                    await viewModel.retry()
                }
            } label: {
                Text("Retry")
                    .font(AppTheme.Typography.body())
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .overlay(
                        Rectangle()
                            .stroke(AppTheme.Colors.border, lineWidth: 2)
                    )
            }
            .disabled(viewModel.state.isLoading)
        }
    }
}

struct ItemRow: View {
    let item: ItemSummary
    @ObservedObject var viewModel: ItemViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            AsyncImage(url: item.imageUrl) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: AppTheme.Layout.itemImageSize,
                            height: AppTheme.Layout.itemImageSize
                        )
                case .failure:
                    Image(systemName: "cube.box")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                        .frame(
                            width: AppTheme.Layout.itemImageSize,
                            height: AppTheme.Layout.itemImageSize
                        )
                default:
                    ProgressView()
                        .frame(
                            width: AppTheme.Layout.itemImageSize,
                            height: AppTheme.Layout.itemImageSize
                        )
                }
            }
            .padding(8)
            .background(AppTheme.Colors.imageBackground(for: colorScheme))
            .overlay(
                Rectangle()
                    .stroke(AppTheme.Colors.border, lineWidth: AppTheme.Layout.itemBorderWidth)
            )
            .shadow(color: AppTheme.Colors.border.opacity(0.3), radius: 4, x: 3, y: 3)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(item.name.replacingOccurrences(of: "-", with: " ").capitalized)
                    .font(AppTheme.Typography.body())
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.Colors.primaryText(for: colorScheme))
                
                // Ici on affiche un aperçu court de la description
                if let itemId = item.itemId,
                   let detail = viewModel.itemDetails[itemId] {
                    Text(detail.englishEffect.removeSpecialCharacters())
                        .font(AppTheme.Typography.caption())
                        .foregroundColor(AppTheme.Colors.secondaryText(for: colorScheme))
                        .lineLimit(2) // On limite à 2 lignes dans la liste pour garder ça compact
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text("Loading description...")
                        .font(AppTheme.Typography.caption(size: 8))
                        .foregroundColor(.gray)
                        .italic()
                }
            }
            .padding(.vertical, 12)
            
            Spacer()
            
            // Chevron indicateur
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .padding(.top, 28)
                .padding(.horizontal, 24)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .background(AppTheme.Colors.cardBackground(for: colorScheme))
        .overlay(
            Rectangle()
                .stroke(AppTheme.Colors.border, lineWidth: AppTheme.Layout.borderWidth)
        )
        // Petit effet de "carte" dans la liste
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .task {
            // Load item details when row appears (for preview description)
            await viewModel.fetchItemDetail(for: item)
        }
    }
}

#Preview {
    ItemsView()
}

// Extension to remove special characters from strings
extension String {
    func removeSpecialCharacters() -> String {
        // Remove accents and diacritics
        let withoutAccents = self.folding(options: .diacriticInsensitive, locale: .current)
        
        // Keep only alphanumeric characters, spaces, and basic punctuation
        let allowedCharacters = CharacterSet.alphanumerics
            .union(.whitespaces)
            .union(CharacterSet(charactersIn: ".,!?-:;()[]"))
        
        return withoutAccents.components(separatedBy: allowedCharacters.inverted).joined()
    }
}
