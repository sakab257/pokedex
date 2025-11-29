//
//  CachedImage.swift
//  Pokedex
//
//  A robust replacement for AsyncImage that uses NSCache
//  to ensure images persist across tabs and lists.
//

import SwiftUI
import Combine

// 1. Le Singleton de Cache (Global à l'app)
class ImageCache {
    // CORRECTION : Initialisation via une closure pour configurer le cache immédiatement
    static let shared: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 200 // Garde 200 images max
        return cache
    }()
}

// 2. Le Loader qui gère le téléchargement
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    
    private let url: URL?
    private var cancellable: AnyCancellable?
    
    init(url: URL?) {
        self.url = url
    }
    
    func load() {
        guard let url = url else { return }
        
        // A. Vérifier le cache d'abord !
        if let cachedImage = ImageCache.shared.object(forKey: url.absoluteString as NSString) {
            self.image = cachedImage
            return
        }
        
        // B. Sinon, télécharger
        isLoading = true
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] downloadedImage in
                self?.isLoading = false
                if let image = downloadedImage {
                    // Sauvegarder dans le cache pour la prochaine fois (ex: Tab Favourites)
                    ImageCache.shared.setObject(image, forKey: url.absoluteString as NSString)
                    self?.image = image
                }
            }
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}

// 3. La Vue SwiftUI réutilisable
struct CachedImage<Content: View, Placeholder: View>: View {
    @StateObject private var loader: ImageLoader
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self._loader = StateObject(wrappedValue: ImageLoader(url: url))
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let uiImage = loader.image {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
            }
        }
        .onAppear {
            loader.load()
        }
        .onDisappear {
            // Optionnel : annuler le téléchargement si on scroll trop vite
            // loader.cancel()
        }
    }
}
