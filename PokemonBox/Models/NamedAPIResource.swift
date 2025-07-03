//
//  NamedAPIResource.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 05/07/25.
//

import Foundation

/// A generic API resource with a name.
struct NamedAPIResource: Decodable {
    let name: String
}
