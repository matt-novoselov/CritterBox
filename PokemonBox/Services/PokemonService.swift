//
//  ViewController.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 01/07/25.
//

import Foundation

/// Constants for building requests to the PokeAPI.
/// Strings used here are collected in ``PokemonAPIConstants`` for type safety.


class PokemonService {
    private let session: URLSession
    private let cache = NSCache<NSURL, NSData>()
    private let baseURL = APIConstants.baseURL

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchPokemonPage(limit: Int = 20, offset: Int = 0) async throws -> PokemonPage {
        let listURL = baseURL
            .appendingPathComponent(APIConstants.Path.pokemonSpecies)
            .appending(queryItems: [
                URLQueryItem(name: APIConstants.Query.limit, value: String(limit)),
                URLQueryItem(name: APIConstants.Query.offset, value: String(offset))
            ])
        let data = try await fetchData(from: listURL)
        let list = try JSONDecoder().decode(PokemonListResponse.self, from: data)
        var result: [Pokemon] = []
        for item in list.results {
            let pokemon = try await fetchPokemon(named: item.name)
            result.append(pokemon)
        }
        return PokemonPage(totalCount: list.count, items: result)
    }

    /// Downloads the list of all Pokemon names.
    /// - Returns: A set of Pokemon names.
    func fetchPokemonNameSet() async throws -> Set<String> {
        let listURL = baseURL
            .appendingPathComponent(APIConstants.Path.pokemonSpecies)
            .appending(queryItems: [URLQueryItem(name: APIConstants.Query.limit, value: APIConstants.Query.limit)])
        let data = try await fetchData(from: listURL)
        let list = try JSONDecoder().decode(PokemonListResponse.self, from: data)
        return Set(list.results.map { $0.name })
    }

    /// Downloads all pokemon names grouped by type name.
    /// - Returns: A dictionary keyed by type name with an array of pokemon names.
    func fetchPokemonTypeMap() async throws -> [String: [String]] {
        let typeListURL = baseURL.appendingPathComponent(APIConstants.Path.type)
        let data = try await fetchData(from: typeListURL)
        let list = try JSONDecoder().decode(PokemonTypeListResponse.self, from: data)
        var result: [String: [String]] = [:]
        try await withThrowingTaskGroup(of: (String, [String]).self) { group in
            for type in list.results {
                group.addTask {
                    let detailData = try await self.fetchData(from: type.url)
                    let detail = try JSONDecoder().decode(PokemonTypeDetailResponse.self, from: detailData)
                    let names = detail.pokemon.map { $0.pokemon.name }
                    return (type.name, names)
                }
            }
            for try await (name, names) in group {
                result[name] = names
            }
        }
        return result
    }

    func fetchPokemon(named name: String) async throws -> Pokemon {
        let detailURL = baseURL
            .appendingPathComponent(APIConstants.Path.pokemon)
            .appendingPathComponent(name)
        let detailRaw = try await fetchData(from: detailURL)
        let detail = try JSONDecoder().decode(PokemonDetailResponse.self, from: detailRaw)

        // Skip forms by reloading canonical species if needed
        if detail.name != detail.species.name {
            return try await fetchPokemon(named: detail.species.name)
        }

        let speciesData = try await fetchData(from: detail.species.url)
        let species = try JSONDecoder().decode(PokemonSpeciesResponse.self, from: speciesData)
        var flavor = species.flavor_text_entries.first { $0.language.name == "en" }?
            .flavor_text
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\u{000c}", with: " ")
        if var text = flavor {
            let sentences = text.split(separator: ".", omittingEmptySubsequences: true)
            if sentences.count > 1, let first = sentences.first {
                text = first.trimmingCharacters(in: .whitespaces) + "."
            }
            flavor = text
        }
        let types = detail.types.map { $0.type.name }
        let artwork = detail.sprites.other.officialArtwork.front_default
        return Pokemon(name: detail.name, flavorText: flavor, types: types, artworkURL: artwork)
    }

    private func fetchData(from url: URL) async throws -> Data {
        if let cached = cache.object(forKey: url as NSURL) {
            return cached as Data
        }
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        cache.setObject(data as NSData, forKey: url as NSURL)
        return data
    }
}

private extension URL {
    func appending(queryItems: [URLQueryItem]) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        components.queryItems = (components.queryItems ?? []) + queryItems
        return components.url!
    }
}
