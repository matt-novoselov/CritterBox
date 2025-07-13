//
//  PokemonCellViewModel.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 05/07/25.
//

import Foundation

/// ViewModel for configuring a PokemonCell.
struct PokemonCellViewModel {
    let name: String
    let types: Set<String>
    let flavorText: String?
    let artworkURL: URL?
    let accessibilityLabel: String

    init(pokemon: Pokemon) {
        name = pokemon.name.capitalized
        types = Set( pokemon.types.map { $0.capitalized })
        flavorText = pokemon.flavorText
        artworkURL = pokemon.artworkURL

        let typesText = types.joined(separator: ", ")
        let description = flavorText ?? "No description provided"
        accessibilityLabel = "\(name), types: \(typesText). \(description)"
    }
}
