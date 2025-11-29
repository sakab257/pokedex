//
//  ItemService.swift
//  Pokedex
//
//  Service layer for Item API calls
//

import Foundation

protocol ItemServiceProtocol {
    func fetchItems(limit: Int) async throws -> [ItemSummary]
    func fetchItemDetail(id: Int) async throws -> ItemDetail
}

class ItemService: ItemServiceProtocol {
    private let baseURL = "https://pokeapi.co/api/v2"
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchItems(limit: Int = 200) async throws -> [ItemSummary] {
        guard let url = URL(string: "\(baseURL)/item?limit=\(limit)") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decodedResponse = try JSONDecoder().decode(ItemResponse.self, from: data)
            return decodedResponse.results
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func fetchItemDetail(id: Int) async throws -> ItemDetail {
        guard let url = URL(string: "\(baseURL)/item/\(id)/") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(ItemDetail.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}
