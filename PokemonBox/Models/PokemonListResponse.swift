//
//  PokemonListResponse.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 05/07/25.
//

import Foundation

/// Response for a paginated list of Pokémon species.
struct PokemonListResponse: Decodable {
    struct Result: Decodable {
        let name: String
        let url: URL
    }
    let count: Int
    let next: URL?
    let previous: URL?
    let results: [Result]
}