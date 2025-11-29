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
    
    // Animation States
    @State private var isFloating = false
    
    init(item: ItemSummary) {
        self.item = item
        _viewModel = StateObject(wrappedValue: ItemDetailViewModel(itemId: item.itemId ?? 0))
    }
    
    var body: some View {
        ZStack {
            // 1. Fond texturé
            AppTheme.Colors.background(for: colorScheme)
                .ignoresSafeArea()
            
            // Watermarks (Pattern de sacs et d'éclairs)
            GeometryReader { geo in
                ZStack {
                    Image(systemName: "backpack.fill")
                        .font(.system(size: 150))
                        .foregroundColor(AppTheme.Colors.secondaryText(for: colorScheme).opacity(0.05))
                        .position(x: geo.size.width * 0.2, y: geo.size.height * 0.15)
                        .rotationEffect(.degrees(-15))
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 100))
                        .foregroundColor(AppTheme.Colors.secondaryText(for: colorScheme).opacity(0.05))
                        .position(x: geo.size.width * 0.85, y: geo.size.height * 0.4)
                    
                    Image(systemName: "cube.box.fill")
                        .font(.system(size: 120))
                        .foregroundColor(AppTheme.Colors.secondaryText(for: colorScheme).opacity(0.05))
                        .position(x: geo.size.width * 0.1, y: geo.size.height * 0.8)
                        .rotationEffect(.degrees(15))
                    
                    // Cercle décoratif
                    Circle()
                        .stroke(lineWidth: 2)
                        .foregroundColor(Color.blue.opacity(0.05))
                        .frame(width: 400, height: 400)
                        .position(x: geo.size.width * 0.5, y: geo.size.height * 0.3)
                }
            }
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    Spacer().frame(height: 20)
                    
                    // 2. Image "Lévitation"
                    headerView
                    
                    // 3. Carte de détail
                    infoCardView
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(item.name.replacingOccurrences(of: "-", with: " ").capitalized)
                    .font(AppTheme.Typography.title(size: 18))
                    .foregroundColor(AppTheme.Colors.primaryText(for: colorScheme))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isFloating = true
            }
        }
    }
    
    private var headerView: some View {
        ZStack {
            // Effet d'ondulation au sol
            Ellipse()
                .fill(.black.opacity(0.1))
                .frame(width: 100, height: 20)
                .scaleEffect(isFloating ? 0.8 : 1.2) // L'ombre rétrécit quand l'objet monte
                .offset(y: 110)
                .blur(radius: 5)
            
            // Cercle de fond avec lueur
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.blue.opacity(0.2), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .frame(width: 250, height: 250)
            
            Circle()
                .stroke(AppTheme.Colors.border.opacity(0.5), lineWidth: 2)
                .frame(width: 180, height: 180)
                .background(Circle().fill(AppTheme.Colors.cardBackground(for: colorScheme)))
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            
            AsyncImage(url: item.imageUrl) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .renderingMode(.original)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .scaleEffect(1.8) // Pixel art bien visible
                        // Animation de lévitation
                        .offset(y: isFloating ? -10 : 10)
                        .shadow(color: .black.opacity(0.2), radius: 5, y: 5)
                case .failure:
                    Image(systemName: "cube.box.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                default:
                    ProgressView()
                }
            }
        }
        .padding(.top, 20)
    }
    
    @ViewBuilder
    private var infoCardView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Bandeau ID
            HStack {
                Text("ITEM DATA")
                    .font(AppTheme.Typography.caption(size: 12))
                    .foregroundColor(.gray)
                    .tracking(2) // Espacement des lettres style sci-fi
                
                Spacer()
                
                if let id = item.itemId {
                    HStack(spacing: 4) {
                        Image(systemName: "number.square.fill")
                        Text("\(id)")
                    }
                    .font(AppTheme.Typography.body())
                    .foregroundColor(.blue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(.bottom, 20)
            
            Divider()
                .padding(.bottom, 20)
            
            // Contenu
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.yellow)
                    Text("Effect")
                        .font(AppTheme.Typography.title(size: 18))
                        .foregroundColor(AppTheme.Colors.primaryText(for: colorScheme))
                }
                
                switch viewModel.state {
                case .loading:
                    HStack {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.2)
                        Spacer()
                    }
                    .padding(30)
                    
                case .loaded(let detail):
                    Text(detail.englishEffect.removeSpecialCharacters())
                        .font(AppTheme.Typography.body(size: 16))
                        .foregroundColor(AppTheme.Colors.primaryText(for: colorScheme).opacity(0.8))
                        .lineSpacing(8) // Meilleure lisibilité
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppTheme.Colors.background(for: colorScheme)) // Fond contrasté dans la carte
                        )
                    
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
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.Colors.border, lineWidth: AppTheme.Layout.borderWidth)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - ViewModel Local (inchangé)
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
