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
    
    var backgroundColor: Color {
        colorScheme == .dark ? Color(hex: "#1A1A1A") : Color(hex: "#F5F5F5")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color that ignores safe area
                backgroundColor
                    .ignoresSafeArea()
                
                List(viewModel.filteredItems) { item in
                    ItemRow(item: item, viewModel: viewModel)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
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
}

struct ItemRow: View {
    let item: ItemSummary
    @ObservedObject var viewModel: ItemViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var backgroundColor: Color {
        colorScheme == .dark ? Color(hex: "#2A2A2A") : .white
    }
    
    var borderColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var imageBackgroundColor: Color {
        colorScheme == .dark ? Color(hex: "#3A3A3A") : Color(.systemGray6)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Item image
            AsyncImage(url: item.imageUrl) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                case .failure:
                    Image(systemName: "cube.box")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                        .frame(width: 60, height: 60)
                default:
                    ProgressView()
                        .frame(width: 60, height: 60)
                }
            }
            .padding(8)
            .background(imageBackgroundColor)
            .overlay(
                Rectangle()
                    .stroke(borderColor, lineWidth: 2)
            )
            .shadow(color: borderColor.opacity(0.3), radius: 4, x: 3, y: 3)
            
            // Item info
            VStack(alignment: .leading, spacing: 8) {
                Text(item.name.replacingOccurrences(of: "-", with: " ").capitalized)
                    .font(.custom("Pixelmix", size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(textColor)
                
                if let itemId = item.itemId,
                   let detail = viewModel.itemDetails[itemId] {
                    Text(detail.englishEffect.removeSpecialCharacters())
                        .font(.custom("Pixelmix", size: 10))
                        .foregroundColor(textColor.opacity(0.7))
                        .lineLimit(5)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text("Loading description...")
                        .font(.custom("Pixelmix", size: 8))
                        .foregroundColor(.gray)
                        .italic()
                }
            }
            .padding(.vertical, 12)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .background(backgroundColor)
        .overlay(
            Rectangle()
                .stroke(borderColor, lineWidth: 3)
        )
        .task {
            // Load item details when row appears
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
