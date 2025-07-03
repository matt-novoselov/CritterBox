//
//  PokemonTypeListResponse.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 05/07/25.
//

import Foundation

/// Response for the list of Pokémon types.
struct PokemonTypeListResponse: Decodable {
    struct Result: Decodable {
        let name: String
        let url: URL
    }
    let results: [Result]
}
