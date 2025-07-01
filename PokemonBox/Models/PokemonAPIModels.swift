import Foundation

struct Pokemon: Codable {
    let name: String
    let flavorText: String?
    let types: [String]
    let artworkURL: URL?
}

struct NamedAPIResource: Codable {
    let name: String
}

struct PokemonListResponse: Codable {
    struct Result: Codable {
        let name: String
        let url: URL
    }
    let results: [Result]
}

struct PokemonDetailResponse: Codable {
    struct TypeEntry: Codable {
        let type: NamedAPIResource
    }
    struct Sprites: Codable {
        struct Other: Codable {
            struct OfficialArtwork: Codable {
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

struct PokemonSpeciesResponse: Codable {
    struct FlavorTextEntry: Codable {
        let flavor_text: String
        let language: NamedAPIResource
    }
    let flavor_text_entries: [FlavorTextEntry]
}
