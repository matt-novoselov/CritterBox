//
//  ViewController.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 01/07/25.
//

import Foundation

struct Pokemon: Decodable {
    let name: String
    let flavorText: String?
    let types: [String]
    let artworkURL: URL?
}

struct NamedAPIResource: Decodable {
    let name: String
}

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

struct PokemonDetailResponse: Decodable {
    struct TypeEntry: Decodable {
        let type: NamedAPIResource
    }
    struct Sprites: Decodable {
        struct Other: Decodable {
            struct OfficialArtwork: Decodable {
                let front_default: URL?
            }
            let officialArtwork: OfficialArtwork
            enum CodingKeys: String, CodingKey {
                case officialArtwork = "official-artwork"
            }
        }
        let other: Other
    }
    let name: String
    let types: [TypeEntry]
    let sprites: Sprites
}

struct PokemonSpeciesResponse: Decodable {
    struct FlavorTextEntry: Decodable {
        let flavor_text: String
        let language: NamedAPIResource
    }
    let flavor_text_entries: [FlavorTextEntry]
}

struct PokemonPage {
    let totalCount: Int
    let items: [Pokemon]
}

struct PokemonTypeListResponse: Decodable {
    struct Result: Decodable {
        let name: String
        let url: URL
    }
    let results: [Result]
}

struct PokemonTypeDetailResponse: Decodable {
    struct PokemonEntry: Decodable {
        let pokemon: NamedAPIResource
    }
    let pokemon: [PokemonEntry]
}
