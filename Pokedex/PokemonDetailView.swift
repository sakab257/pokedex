//
//  PokemonDetailView.swift
//  Pokedex
//
//  Created by Salim on 29/11/2025.
//

import SwiftUI
import Combine

struct PokemonDetailView: View {
    let pokemon: Pokemon
    @StateObject private var viewModel: PokemonDetailViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    init(pokemon: Pokemon) {
        self.pokemon = pokemon
        // Initialize the ViewModel with the specific pokemon ID
        _viewModel = StateObject(wrappedValue: PokemonDetailViewModel(pokemonId: pokemon.pokemonId ?? 1))
    }
    
    var body: some View {
        ZStack {
            // Background color based on Pokemon type
            pokemon.backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header (Name & ID)
                    headerView
                    
                    // Main Image
                    imageView
                    
                    // Data Card
                    dataCardView
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // TODO: Implement toggle favourite
                }) {
                    Image(systemName: "heart")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack(alignment: .bottom) {
            Text(pokemon.name.capitalized)
                .font(AppTheme.Typography.title(size: 32))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 2, y: 2)
            
            Spacer()
            
            if let id = pokemon.pokemonId {
                Text(String(format: "#%03d", id))
                    .font(AppTheme.Typography.pokemonNumber(size: 24))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
    
    private var imageView: some View {
        ZStack {
            // Subtle pixelated circle glow behind
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 250, height: 250)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 4)
                )
            
            AsyncImage(url: pokemon.imageUrl) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 240, height: 240)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
                case .failure:
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white.opacity(0.5))
                default:
                    ProgressView()
                        .tint(.white)
                }
            }
        }
        .padding(.vertical, 30)
    }
    
    @ViewBuilder
    private var dataCardView: some View {
        VStack(spacing: 24) {
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .scaleEffect(1.5)
                    .padding(50)
                
            case .error(let message):
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text(message)
                        .font(AppTheme.Typography.body())
                        .multilineTextAlignment(.center)
                }
                .padding(50)
                
            case .loaded(let detail):
                // Types
                typesView(types: detail.typeNames)
                
                // Physical Stats (Weight/Height)
                physicalStatsView(detail: detail)
                
                // Base Stats
                baseStatsView(stats: detail.stats)
            }
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .background(AppTheme.Colors.cardBackground(for: colorScheme))
        .cornerRadius(30) // Rounded top corners
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(AppTheme.Colors.border, lineWidth: AppTheme.Layout.borderWidth)
        )
        .padding(.top, -20) // Overlap slightly with image
    }
    
    private func typesView(types: [String]) -> some View {
        HStack(spacing: 16) {
            ForEach(types, id: \.self) { type in
                Text(type.capitalized)
                    .font(AppTheme.Typography.body())
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .background(TypeColorHelper.color(for: type))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(AppTheme.Colors.border, lineWidth: 2)
                    )
            }
        }
    }
    
    private func physicalStatsView(detail: PokemonDetail) -> some View {
        HStack(spacing: 40) {
            VStack(spacing: 8) {
                Text("Weight")
                    .font(AppTheme.Typography.caption(size: 14))
                    .foregroundColor(.gray)
                
                HStack(spacing: 4) {
                    Image(systemName: "scalemass")
                    Text(String(format: "%.1f KG", detail.weightInKg))
                }
                .font(AppTheme.Typography.body())
            }
            
            Divider()
                .frame(height: 40)
            
            VStack(spacing: 8) {
                Text("Height")
                    .font(AppTheme.Typography.caption(size: 14))
                    .foregroundColor(.gray)
                
                HStack(spacing: 4) {
                    Image(systemName: "ruler")
                    Text(String(format: "%.1f M", detail.heightInMeters))
                }
                .font(AppTheme.Typography.body())
            }
        }
    }
    
    private func baseStatsView(stats: [PokemonDetail.PokemonStat]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Base Stats")
                .font(AppTheme.Typography.title(size: 18))
                .padding(.bottom, 8)
            
            ForEach(stats) { stat in
                HStack {
                    Text(statShortName(stat.stat.name))
                        .font(AppTheme.Typography.body())
                        .foregroundColor(.gray)
                        .frame(width: 40, alignment: .leading)
                    
                    Text("\(stat.baseStat)")
                        .font(AppTheme.Typography.body())
                        .fontWeight(.bold)
                        .frame(width: 35, alignment: .trailing)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 12)
                            
                            Rectangle()
                                .fill(statColor(stat.baseStat))
                                .frame(width: geometry.size.width * (CGFloat(stat.baseStat) / 255.0), height: 12)
                        }
                        .cornerRadius(6)
                    }
                    .frame(height: 12)
                }
            }
        }
    }
    
    // Helpers
    private func statShortName(_ name: String) -> String {
        switch name {
        case "hp": return "HP"
        case "attack": return "ATK"
        case "defense": return "DEF"
        case "special-attack": return "SATK"
        case "special-defense": return "SDEF"
        case "speed": return "SPD"
        default: return name.prefix(3).uppercased()
        }
    }
    
    private func statColor(_ value: Int) -> Color {
        if value < 50 { return .red }
        if value < 80 { return .orange }
        if value < 110 { return .green }
        return .cyan
    }
}

// MARK: - Local ViewModel
@MainActor
class PokemonDetailViewModel: ObservableObject {
    enum State {
        case loading
        case loaded(PokemonDetail)
        case error(String)
    }
    
    @Published var state: State = .loading
    private let repository: PokemonRepositoryProtocol
    private let pokemonId: Int
    
    init(pokemonId: Int, repository: PokemonRepositoryProtocol = PokemonRepository()) {
        self.pokemonId = pokemonId
        self.repository = repository
        
        Task {
            await fetchDetail()
        }
    }
    
    func fetchDetail() async {
        state = .loading
        do {
            let detail = try await repository.getPokemonDetail(id: pokemonId)
            state = .loaded(detail)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}

// MARK: - Type Color Helper
struct TypeColorHelper {
    static func color(for type: String) -> Color {
        switch type.lowercased() {
        case "fire": return Color(hex: "#EE8130")
        case "water": return Color(hex: "#6390F0")
        case "grass": return Color(hex: "#7AC74C")
        case "electric": return Color(hex: "#F7D02C")
        case "ice": return Color(hex: "#96D9D6")
        case "fighting": return Color(hex: "#C22E28")
        case "poison": return Color(hex: "#A33EA1")
        case "ground": return Color(hex: "#E2BF65")
        case "flying": return Color(hex: "#A98FF3")
        case "psychic": return Color(hex: "#F95587")
        case "bug": return Color(hex: "#A6B91A")
        case "rock": return Color(hex: "#B6A136")
        case "ghost": return Color(hex: "#735797")
        case "dragon": return Color(hex: "#6F35FC")
        case "steel": return Color(hex: "#B7B7CE")
        case "fairy": return Color(hex: "#D685AD")
        default: return Color.gray
        }
    }
}
