import Foundation

struct Pokemon: Codable {
    let name: String
    let flavorText: String?
    let eggGroups: [String]
    let types: [String]
    let shinyArtworkURL: URL?
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
                let front_shiny: URL?
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
    let egg_groups: [NamedAPIResource]
}

class PokemonService {
    private let session: URLSession
    private let baseURL = URL(string: "https://pokeapi.co/api/v2")!

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchAllPokemon(limit: Int = 2000) async throws -> [Pokemon] {
        let listURL = baseURL.appendingPathComponent("pokemon").appending(queryItems: [URLQueryItem(name: "limit", value: String(limit))])
        let (data, _) = try await session.data(from: listURL)
        let list = try JSONDecoder().decode(PokemonListResponse.self, from: data)
        var result: [Pokemon] = []
        for item in list.results {
            let pokemon = try await fetchPokemon(named: item.name)
            result.append(pokemon)
        }
        return result
    }

    private func fetchPokemon(named name: String) async throws -> Pokemon {
        let detailURL = baseURL.appendingPathComponent("pokemon").appendingPathComponent(name)
        let speciesURL = baseURL.appendingPathComponent("pokemon-species").appendingPathComponent(name)
        async let detailData = session.data(from: detailURL)
        async let speciesData = session.data(from: speciesURL)
        let (detailRaw, _) = try await detailData
        let (speciesRaw, _) = try await speciesData
        let detail = try JSONDecoder().decode(PokemonDetailResponse.self, from: detailRaw)
        let species = try JSONDecoder().decode(PokemonSpeciesResponse.self, from: speciesRaw)
        let flavor = species.flavor_text_entries.first { $0.language.name == "en" }?.flavor_text
        let eggs = species.egg_groups.map { $0.name }
        let types = detail.types.map { $0.type.name }
        let artwork = detail.sprites.other.officialArtwork.front_shiny
        return Pokemon(name: detail.name, flavorText: flavor, eggGroups: eggs, types: types, shinyArtworkURL: artwork)
    }
}

private extension URL {
    func appending(queryItems: [URLQueryItem]) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        components.queryItems = (components.queryItems ?? []) + queryItems
        return components.url!
    }
}
