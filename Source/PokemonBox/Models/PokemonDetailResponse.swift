//
//  PokemonDetailResponse.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 05/07/25.
//

import Foundation

/// Detailed information response for a single Pokémon.
struct PokemonDetailResponse: Decodable {
    let name: String
    let types: [TypeEntry]
    let species: Species
    let sprites: Sprites
}

// Extension for local Species struct
extension PokemonDetailResponse {
    struct Species: Decodable {
        let name: String
        let url: URL
    }
}

// Extension for local TypeEntry struct
extension PokemonDetailResponse {
    struct TypeEntry: Decodable {
        let type: NamedAPIResource
    }
}

// Extension for local Sprites struct
extension PokemonDetailResponse {
    struct Sprites: Decodable {
        struct Other: Decodable {
            struct OfficialArtwork: Decodable {
                let frontDefault: URL?
            }
            let officialArtwork: OfficialArtwork
            enum CodingKeys: String, CodingKey {
                case officialArtwork = "official-artwork"
            }
        }
        let other: Other
    }
}
