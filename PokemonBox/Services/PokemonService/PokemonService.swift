//
//  ViewController.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 01/07/25.
//

import Foundation

/// Constants for building requests to the PokeAPI.
/// Strings used here are collected in ``PokemonAPIConstants`` for type safety.


/// A service layer for fetching Pokémon data from the PokéAPI.
/// Wraps URLSession and provides paging, detail, name‑set, and type‑map methods.
class PokemonService {
    private let session: URLSession
    private let cache = NSCache<NSURL, NSData>()
    private let decoder = JSONDecoder()

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Fetches a page of Pokémon (species) and their details.
    func fetchPokemonPage(limit: Int = AppConstants.pageLimit, offset: Int = 0) async throws -> PokemonPage {
        let list: PokemonListResponse = try await request(PokemonListResponse.self,
                                                        from: .speciesList(limit: limit, offset: offset))
        var items = [Pokemon]()
        for entry in list.results {
            let pokemon = try await fetchPokemon(named: entry.name)
            items.append(pokemon)
        }
        return PokemonPage(totalCount: list.count, items: items)
    }

    /// Downloads the list of all Pokemon names.
    /// - Returns: A set of Pokemon names.
    /// Fetches all Pokémon species names (unlimited limit) as a name set.
    func fetchPokemonNameSet() async throws -> Set<String> {
        let list: PokemonListResponse = try await request(PokemonListResponse.self,
                                                        from: .speciesListAll)
        return Set(list.results.map { $0.name })
    }

    /// Downloads all pokemon names grouped by type name.
    /// - Returns: A dictionary keyed by type name with an array of pokemon names.
    /// Fetches all Pokémon grouped by type name.
    func fetchPokemonTypeMap() async throws -> [String: [String]] {
        let list: PokemonTypeListResponse = try await request(PokemonTypeListResponse.self,
                                                           from: .typeList)
        var map = [String: [String]]()
        try await withThrowingTaskGroup(of: (String, [String]).self) { group in
            for entry in list.results {
                group.addTask {
                    let detail: PokemonTypeDetailResponse = try await self.request(
                        PokemonTypeDetailResponse.self,
                        from: .typeDetail(url: entry.url)
                    )
                    let names = detail.pokemon.map { $0.pokemon.name }
                    return (entry.name, names)
                }
            }
            for try await (type, names) in group {
                map[type] = names
            }
        }
        return map
    }

    func fetchPokemon(named name: String) async throws -> Pokemon {
        let detail: PokemonDetailResponse = try await request(
            PokemonDetailResponse.self,
            from: .pokemonDetail(name: name)
        )

        // Skip forms by reloading canonical species if needed
        if detail.name != detail.species.name {
            return try await fetchPokemon(named: detail.species.name)
        }

        let species: PokemonSpeciesResponse = try await request(
            PokemonSpeciesResponse.self,
            from: .speciesDetail(url: detail.species.url)
        )
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

    // MARK: - Networking Helpers

    private func request<T: Decodable>(_ type: T.Type,
                                       from endpoint: PokemonAPIEndpoint) async throws -> T {
        let data = try await fetchData(from: endpoint.url)
        return try decoder.decode(type, from: data)
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
