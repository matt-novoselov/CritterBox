//
//  PokemonPage.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 05/07/25.
//

import Foundation

/// A page of Pokémon with total count metadata.
struct PokemonPage {
    let totalCount: Int
    let items: [Pokemon]
}
