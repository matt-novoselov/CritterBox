//
//  PokemonService+Network.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 05/07/25.
//

import Foundation

private let jsonDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
}()

extension PokemonService {
    /// Generic request for decoding API responses.
    func request<T: Decodable>(_ type: T.Type,
                               from endpoint: PokemonAPIEndpoint) async throws -> T {
        let data = try await fetchData(from: endpoint.url)
        return try jsonDecoder.decode(type, from: data)
    }

    /// Raw data fetch with simple in-memory caching.
    func fetchData(from url: URL) async throws -> Data {
        if let cached = cache.object(forKey: url as NSURL) {
            return cached as Data
        }
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        cache.setObject(data as NSData, forKey: url as NSURL)
        return data
    }
}
