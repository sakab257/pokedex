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
    
    // Animation states
    @State private var animateStats = false
    @State private var rotateBackground = false
    
    init(pokemon: Pokemon) {
        self.pokemon = pokemon
        _viewModel = StateObject(wrappedValue: PokemonDetailViewModel(pokemonId: pokemon.pokemonId ?? 1))
    }
    
    var body: some View {
        ZStack {
            // 1. FOND DYNAMIQUE
            backgroundLayer
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header (Nom & ID)
                    headerView
                        .padding(.top, 20)
                    
                    // Image Principale
                    imageView
                        .padding(.vertical, 20)
                    
                    // Carte de Données (Glassmorphism style)
                    dataCardView
                        .padding(.top, 20)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // TODO: Implement toggle favourite
                }) {
                    Image(systemName: "heart.fill") // Changé en fill pour le style
                        .foregroundColor(.white.opacity(0.8))
                        .shadow(color: .black.opacity(0.2), radius: 2)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                animateStats = true
            }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotateBackground = true
            }
        }
    }
    
    // MARK: - Visual Components
    
    private var backgroundLayer: some View {
        ZStack {
            // Couleur de base avec dégradé
            LinearGradient(
                colors: [pokemon.backgroundColor, pokemon.backgroundColor.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Watermark Pokeball Géante
            GeometryReader { geo in
                Image("Frame 1") // Ta texture Pokeball
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .opacity(0.15)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geo.size.width * 1.5)
                    .position(x: geo.size.width * 0.8, y: geo.size.height * 0.2)
//                    .rotationEffect(.degrees(rotateBackground ? 360 : 0))
                    .blur(radius: 2)
            }
            
            // Particules décoratives (Cercles flous)
            Circle()
                .fill(.white.opacity(0.1))
                .frame(width: 200, height: 200)
                .blur(radius: 50)
                .offset(x: -100, y: -200)
            
            Circle()
                .fill(.black.opacity(0.1))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: 150, y: 300)
        }
    }
    
    private var headerView: some View {
        HStack(alignment: .bottom) {
            Text(pokemon.name.capitalized)
                .font(AppTheme.Typography.title(size: 36))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 2, y: 2)
            
            Spacer()
            
            if let id = pokemon.pokemonId {
                Text(String(format: "#%03d", id))
                    .font(AppTheme.Typography.pokemonNumber(size: 24))
                    .fontWeight(.black)
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.1), radius: 2)
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var imageView: some View {
        ZStack {
            // Aura brillante derrière le Pokémon
            Circle()
                .fill(.white.opacity(0.2))
                .frame(width: 260, height: 260)
                .blur(radius: 10)
            
            Circle()
                .stroke(.white.opacity(0.5), lineWidth: 2)
                .frame(width: 250, height: 250)
                .overlay(
                    Circle()
                        .stroke(style: StrokeStyle(lineWidth: 10, dash: [5, 15]))
                        .foregroundColor(.white.opacity(0.3))
                        .frame(width: 280, height: 280)
                        .rotationEffect(.degrees(rotateBackground ? -360 : 0)) // Tourne en sens inverse
                )
            
            AsyncImage(url: pokemon.imageUrl) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 240, height: 240)
                        .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 10)
                        .scaleEffect(animateStats ? 1.0 : 0.8) // Petit pop à l'apparition
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: animateStats)
                case .failure:
                    Image(systemName: "questionmark")
                        .font(.system(size: 80))
                        .foregroundColor(.white.opacity(0.5))
                default:
                    ProgressView()
                        .tint(.white)
                }
            }
        }
    }
    
    @ViewBuilder
    private var dataCardView: some View {
        VStack(spacing: 30) {
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .scaleEffect(1.5)
                    .padding(50)
                    .tint(AppTheme.Colors.primaryText(for: colorScheme))
                
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
                // Types (Badges modernes)
                typesView(types: detail.typeNames)
                
                // Stats Physiques (Poids/Taille)
                physicalStatsView(detail: detail)
                
                // Base Stats (Barres animées)
                baseStatsView(stats: detail.stats, color: pokemon.backgroundColor)
            }
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .background(
            // Fond blanc/noir style "Carte" avec bords arrondis
            AppTheme.Colors.cardBackground(for: colorScheme)
                .opacity(0.95) // Légère transparence
        )
        .cornerRadius(40, corners: [.topLeft, .topRight]) // Coin custom (voir extension plus bas)
        .shadow(color: .black.opacity(0.1), radius: 20, y: -5)
    }
    
    private func typesView(types: [String]) -> some View {
        HStack(spacing: 16) {
            ForEach(types, id: \.self) { type in
                HStack(spacing: 8) {
                    // Petite icône de type (système pour l'instant)
                    Image(systemName: "flame.fill") // Placeholder, idéalement une icône spécifique
                        .font(.caption)
                    Text(type.capitalized)
                        .font(AppTheme.Typography.body())
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .foregroundColor(.white)
                .background(TypeColorHelper.color(for: type))
                .clipShape(Capsule())
                .shadow(color: TypeColorHelper.color(for: type).opacity(0.5), radius: 5, y: 3)
            }
        }
    }
    
    private func physicalStatsView(detail: PokemonDetail) -> some View {
        HStack(spacing: 40) {
            statItem(title: "Weight", value: String(format: "%.1f KG", detail.weightInKg), icon: "scalemass.fill")
            
            Divider()
                .frame(height: 40)
                .background(Color.gray.opacity(0.3))
            
            statItem(title: "Height", value: String(format: "%.1f M", detail.heightInMeters), icon: "ruler.fill")
        }
        .padding(.vertical, 10)
    }
    
    private func statItem(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                Text(title)
                    .font(AppTheme.Typography.caption(size: 14))
                    .foregroundColor(.gray)
            }
            
            Text(value)
                .font(AppTheme.Typography.title(size: 20)) // Plus gros
                .foregroundColor(AppTheme.Colors.primaryText(for: colorScheme))
        }
    }
    
    private func baseStatsView(stats: [PokemonDetail.PokemonStat], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Base Stats")
                .font(AppTheme.Typography.title(size: 22))
                .foregroundColor(color) // Titre coloré comme le Pokemon
                .padding(.bottom, 5)
            
            ForEach(stats) { stat in
                HStack(spacing: 12) {
                    Text(statShortName(stat.stat.name))
                        .font(AppTheme.Typography.body(size: 12))
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .frame(width: 45, alignment: .leading)
                    
                    Text("\(stat.baseStat)")
                        .font(AppTheme.Typography.body())
                        .fontWeight(.bold)
                        .frame(width: 35, alignment: .trailing)
                    
                    // Barre de progression animée
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 10)
                            
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [statColor(stat.baseStat), statColor(stat.baseStat).opacity(0.6)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: animateStats ? geometry.size.width * (CGFloat(stat.baseStat) / 255.0) : 0, height: 10)
                        }
                    }
                    .frame(height: 10)
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

// Extension pour arrondir seulement certains coins
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Local ViewModel (inchangé)
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

// MARK: - Type Color Helper (inchangé)
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
