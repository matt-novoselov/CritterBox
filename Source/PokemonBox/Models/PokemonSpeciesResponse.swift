//
//  PokemonSpeciesResponse.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 05/07/25.
//

import Foundation

/// Response for species-level data, including flavor text entries.
struct PokemonSpeciesResponse: Decodable {
    struct FlavorTextEntry: Decodable {
        let flavorText: String
        let language: NamedAPIResource
    }
    let flavorTextEntries: [FlavorTextEntry]
}
