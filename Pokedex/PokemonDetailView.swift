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
    @ObservedObject private var favouritesManager = FavouritesManager.shared
    
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
            // FOND
            backgroundLayer
            
            ScrollView {
                VStack(spacing: 0) {
                    headerView.padding(.top, 20)
                    imageView.padding(.vertical, 20)
                    dataCardView.padding(.top, 20)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    favouritesManager.toggleFavourite(pokemon: pokemon)
                }) {
                    Image(systemName: favouritesManager.isFavourite(pokemon: pokemon) ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundColor(favouritesManager.isFavourite(pokemon: pokemon) ? .red : .white)
                        .shadow(color: .black.opacity(0.2), radius: 2)
                        .scaleEffect(favouritesManager.isFavourite(pokemon: pokemon) ? 1.1 : 1.0)
                        .animation(.spring(), value: favouritesManager.isFavourite(pokemon: pokemon))
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) { animateStats = true }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) { rotateBackground = true }
        }
    }
    
    // MARK: - Composants Visuels
    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [pokemon.backgroundColor, pokemon.backgroundColor.opacity(0.6)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ).ignoresSafeArea()
            
            GeometryReader { geo in
                Image("Frame 1")
                    .resizable().renderingMode(.template)
                    .foregroundColor(.white).opacity(0.15)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geo.size.width * 1.5)
                    .position(x: geo.size.width * 0.8, y: geo.size.height * 0.2)
                    .blur(radius: 2)
            }
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
            Circle().fill(.white.opacity(0.2)).frame(width: 260, height: 260).blur(radius: 10)
            Circle().stroke(.white.opacity(0.5), lineWidth: 2).frame(width: 250, height: 250)
            
            AsyncImage(url: pokemon.imageUrl) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fit)
                        .frame(width: 240, height: 240)
                        .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 10)
                        .scaleEffect(animateStats ? 1.0 : 0.8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: animateStats)
                default: ProgressView().tint(.white)
                }
            }
            .id(pokemon.imageUrl)
        }
    }
    
    @ViewBuilder
    private var dataCardView: some View {
        VStack(spacing: 30) {
            switch viewModel.state {
            case .loading:
                ProgressView().scaleEffect(1.5).padding(50).tint(AppTheme.Colors.primaryText(for: colorScheme))
            case .error(let message):
                Text(message).foregroundColor(.red)
            case .loaded(let detail):
                typesView(types: detail.typeNames)
                physicalStatsView(detail: detail)
                baseStatsView(stats: detail.stats, color: pokemon.backgroundColor)
                Divider().padding(.horizontal)
                evolutionsView(color: pokemon.backgroundColor)
            }
        }
        .padding(.vertical, 32).padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .background(AppTheme.Colors.cardBackground(for: colorScheme).opacity(0.95))
        .cornerRadius(40, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.1), radius: 20, y: -5)
    }
    
    // --- Sous-Vues ---
    
    private func typesView(types: [String]) -> some View {
        HStack(spacing: 16) {
            ForEach(types, id: \.self) { type in
                Text(type.capitalized)
                    .font(AppTheme.Typography.body())
                    .fontWeight(.bold)
                    .padding(.horizontal, 20).padding(.vertical, 10)
                    .foregroundColor(.white)
                    .background(TypeColorHelper.color(for: type))
                    .clipShape(Capsule())
            }
        }
    }
    
    private func physicalStatsView(detail: PokemonDetail) -> some View {
        HStack(spacing: 40) {
            VStack {
                Text("Weight").foregroundColor(.gray).font(AppTheme.Typography.caption())
                Text(String(format: "%.1f KG", detail.weightInKg)).font(AppTheme.Typography.title(size: 20))
            }
            Divider().frame(height: 40)
            VStack {
                Text("Height").foregroundColor(.gray).font(AppTheme.Typography.caption())
                Text(String(format: "%.1f M", detail.heightInMeters)).font(AppTheme.Typography.title(size: 20))
            }
        }
    }
    
    private func baseStatsView(stats: [PokemonDetail.PokemonStat], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Base Stats").font(AppTheme.Typography.title(size: 22)).foregroundColor(color)
            ForEach(stats) { stat in
                HStack {
                    Text(stat.stat.name.prefix(3).uppercased()).foregroundColor(.gray).frame(width: 45, alignment: .leading)
                    Text("\(stat.baseStat)").fontWeight(.bold).frame(width: 35, alignment: .trailing)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.gray.opacity(0.1))
                            Capsule().fill(color).frame(width: animateStats ? geo.size.width * (CGFloat(stat.baseStat) / 255.0) : 0)
                        }
                    }.frame(height: 10)
                }
            }
        }
    }
    
    // --- NOUVEAU: Vue des Évolutions ---
    @ViewBuilder
    private func evolutionsView(color: Color) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Evolution Chain")
                .font(AppTheme.Typography.title(size: 22))
                .foregroundColor(color)
            
            if viewModel.evolutions.isEmpty {
                if viewModel.isLoadingEvolutions {
                    ProgressView().frame(maxWidth: .infinity)
                } else {
                    Text("No evolutions found").foregroundColor(.gray)
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(Array(viewModel.evolutions.enumerated()), id: \.element.id) { index, evoPokemon in
                            if index > 0 {
                                Image(systemName: "arrow.right").foregroundColor(.gray)
                            }
                            
                            NavigationLink(destination: PokemonDetailView(pokemon: evoPokemon)) {
                                VStack {
                                    ZStack {
                                        Circle().fill(evoPokemon.backgroundColor.opacity(0.1)).frame(width: 70, height: 70)
                                        CachedImage(url: evoPokemon.imageUrl) { img in
                                            img.resizable().scaledToFit().frame(width: 60, height: 60)
                                        } placeholder: { ProgressView().scaleEffect(0.5) }
                                    }
                                    Text(evoPokemon.name.capitalized)
                                        .font(AppTheme.Typography.caption())
                                        .foregroundColor(AppTheme.Colors.primaryText(for: colorScheme))
                                }
                                .padding(10)
                                .background(RoundedRectangle(cornerRadius: 12).stroke(pokemon.pokemonId == evoPokemon.pokemonId ? color : Color.clear, lineWidth: 2))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 5)
                }
            }
        }
    }
}

// MARK: - ViewModel
@MainActor
class PokemonDetailViewModel: ObservableObject {
    enum State {
        case loading, loaded(PokemonDetail), error(String)
    }
    
    @Published var state: State = .loading
    @Published var evolutions: [Pokemon] = []
    @Published var isLoadingEvolutions = false
    
    private let repository: PokemonRepositoryProtocol
    private let pokemonId: Int
    
    init(pokemonId: Int, repository: PokemonRepositoryProtocol = PokemonRepository()) {
        self.pokemonId = pokemonId
        self.repository = repository
        Task {
            await fetchDetail()
            await fetchEvolutions()
        }
    }
    
    func fetchDetail() async {
        do {
            let detail = try await repository.getPokemonDetail(id: pokemonId)
            state = .loaded(detail)
        } catch { state = .error(error.localizedDescription) }
    }
    
    func fetchEvolutions() async {
        isLoadingEvolutions = true
        do {
            evolutions = try await repository.getEvolutionChain(for: pokemonId)
        } catch { print("Evo error: \(error)") }
        isLoadingEvolutions = false
    }
}

// Helpers
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity; var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
struct TypeColorHelper {
    static func color(for type: String) -> Color {
        switch type.lowercased() {
        case "fire": return Color(hex: "#EE8130"); case "water": return Color(hex: "#6390F0"); case "grass": return Color(hex: "#7AC74C"); case "electric": return Color(hex: "#F7D02C"); case "ice": return Color(hex: "#96D9D6"); case "fighting": return Color(hex: "#C22E28"); case "poison": return Color(hex: "#A33EA1"); case "ground": return Color(hex: "#E2BF65"); case "flying": return Color(hex: "#A98FF3"); case "psychic": return Color(hex: "#F95587"); case "bug": return Color(hex: "#A6B91A"); case "rock": return Color(hex: "#B6A136"); case "ghost": return Color(hex: "#735797"); case "dragon": return Color(hex: "#6F35FC"); case "steel": return Color(hex: "#B7B7CE"); case "fairy": return Color(hex: "#D685AD"); default: return Color.gray
        }
    }
}
