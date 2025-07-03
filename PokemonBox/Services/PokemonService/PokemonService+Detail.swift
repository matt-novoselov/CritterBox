//
//  PokemonService+Detail.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 05/07/25.
//

import Foundation

extension PokemonService {
    /// Fetches detailed information for a single Pokémon species, including flavor text and artwork.
    func fetchPokemon(named name: String) async throws -> Pokemon {
        let detail: PokemonDetailResponse = try await request(
            PokemonDetailResponse.self,
            from: .pokemonDetail(name: name)
        )

        // Skip non-canonical forms by reloading species-level data
        if detail.name != detail.species.name {
            return try await fetchPokemon(named: detail.species.name)
        }

        let species: PokemonSpeciesResponse = try await request(
            PokemonSpeciesResponse.self,
            from: .speciesDetail(url: detail.species.url)
        )
        var flavor = species.flavorTextEntries
            .first(where: { $0.language.name == "en" })?
            .flavorText
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
        let artwork = detail.sprites.other.officialArtwork.frontDefault
        return Pokemon(name: detail.name,
                       flavorText: flavor,
                       types: types,
                       artworkURL: artwork)
    }
}
