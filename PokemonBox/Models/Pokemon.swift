//
//  Pokemon.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 05/07/25.
//

import Foundation

/// A single Pokémon with its display-ready properties.
struct Pokemon: Decodable {
    let name: String
    let flavorText: String?
    let types: [String]
    let artworkURL: URL?
}