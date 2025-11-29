//
//  ItemDetailView.swift
//  Pokedex
//
//  Created by Salim on 29/11/2025.
//

import SwiftUI
import Combine

struct ItemDetailView: View {
    let item: ItemSummary
    @StateObject private var viewModel: ItemDetailViewModel
    @Environment(\.colorScheme) var colorScheme
    
    init(item: ItemSummary) {
        self.item = item
        // On initialise le ViewModel avec l'ID de l'item
        _viewModel = StateObject(wrappedValue: ItemDetailViewModel(itemId: item.itemId ?? 0))
    }
    
    var body: some View {
        ZStack {
            // Fond général
            AppTheme.Colors.background(for: colorScheme)
                .ignoresSafeArea()
            
            // Décoration d'arrière-plan (optionnel, comme une texture)
            VStack {
                Spacer()
                Image(systemName: "backpack.fill")
                    .font(.system(size: 200))
                    .foregroundColor(AppTheme.Colors.secondaryText(for: colorScheme).opacity(0.05))
                    .rotationEffect(.degrees(-15))
                    .offset(x: 100, y: 100)
            }
            
            ScrollView {
                VStack(spacing: 24) {
                    // 1. En-tête (Image)
                    headerView
                    
                    // 2. Carte d'information
                    infoCardView
                }
                .padding(.bottom, 30)
            }
        }
        .navigationTitle(item.name.replacingOccurrences(of: "-", with: " ").capitalized)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerView: some View {
        ZStack {
            Circle()
                .fill(AppTheme.Colors.cardBackground(for: colorScheme))
                .frame(width: 180, height: 180)
                .overlay(
                    Circle()
                        .stroke(AppTheme.Colors.border, lineWidth: 4)
                )
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            AsyncImage(url: item.imageUrl) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .renderingMode(.original)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .scaleEffect(1.5) // Pixel art plus gros
                case .failure:
                    Image(systemName: "cube.box.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                default:
                    ProgressView()
                }
            }
        }
        .padding(.top, 40)
    }
    
    @ViewBuilder
    private var infoCardView: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Titre
            HStack {
                Text(item.name.replacingOccurrences(of: "-", with: " ").capitalized)
                    .font(AppTheme.Typography.title(size: 24))
                    .foregroundColor(AppTheme.Colors.primaryText(for: colorScheme))
                
                Spacer()
                
                if let id = item.itemId {
                    Text("Number: \(id)")
                        .font(AppTheme.Typography.body())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            Divider()
            
            // Description
            VStack(alignment: .leading, spacing: 12) {
                Text("Effect")
                    .font(AppTheme.Typography.body(size: 16))
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.Colors.secondaryText(for: colorScheme))
                
                switch viewModel.state {
                case .loading:
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding()
                        Spacer()
                    }
                    
                case .loaded(let detail):
                    Text(detail.englishEffect.removeSpecialCharacters())
                        .font(AppTheme.Typography.body(size: 16))
                        .foregroundColor(AppTheme.Colors.primaryText(for: colorScheme))
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                    
                case .error(let message):
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                        Text(message)
                            .font(AppTheme.Typography.caption())
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding(24)
        .background(AppTheme.Colors.cardBackground(for: colorScheme))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.Colors.border, lineWidth: AppTheme.Layout.borderWidth)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - ViewModel Local
@MainActor
class ItemDetailViewModel: ObservableObject {
    enum State {
        case loading
        case loaded(ItemDetail)
        case error(String)
    }
    
    @Published var state: State = .loading
    private let repository: ItemRepositoryProtocol
    private let itemId: Int
    
    init(itemId: Int, repository: ItemRepositoryProtocol = ItemRepository()) {
        self.itemId = itemId
        self.repository = repository
        
        Task {
            await fetchDetail()
        }
    }
    
    func fetchDetail() async {
        state = .loading
        do {
            let detail = try await repository.getItemDetail(id: itemId)
            state = .loaded(detail)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
