//
//  PokemonTypeDetailResponse.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 05/07/25.
//

import Foundation

/// Detail response for a single Pokémon type, including all Pokémon entries.
struct PokemonTypeDetailResponse: Decodable {
    struct PokemonEntry: Decodable {
        let pokemon: NamedAPIResource
    }
    let pokemon: [PokemonEntry]
}
