import Foundation


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
        var flavor = species.flavor_text_entries.first { $0.language.name == "en" }?
            .flavor_text
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\u{000c}", with: " ")
        if var text = flavor {
            let sentences = text.split(separator: ".", omittingEmptySubsequences: true)
            if sentences.count > 1, let first = sentences.first {
                text = first.trimmingCharacters(in: .whitespaces) + "."
            }
            flavor = text
        }
        let types = detail.types.map { $0.type.name }
        let artwork = detail.sprites.other.officialArtwork.front_default
        return Pokemon(name: detail.name, flavorText: flavor, types: types, artworkURL: artwork)
    }
}

private extension URL {
    func appending(queryItems: [URLQueryItem]) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        components.queryItems = (components.queryItems ?? []) + queryItems
        return components.url!
    }
}
