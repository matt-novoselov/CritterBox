import Foundation


class PokemonService {
    private let session: URLSession
    private let baseURL = URL(string: "https://pokeapi.co/api/v2")!

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchPokemonPage(limit: Int = 20, offset: Int = 0) async throws -> PokemonPage {
        let listURL = baseURL
            .appendingPathComponent("pokemon")
            .appending(queryItems: [
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "offset", value: String(offset))
            ])
        let data = try await fetchData(from: listURL)
        let list = try JSONDecoder().decode(PokemonListResponse.self, from: data)
        var result: [Pokemon] = []
        for item in list.results {
            let pokemon = try await fetchPokemon(named: item.name)
            result.append(pokemon)
        }
        return PokemonPage(totalCount: list.count, items: result)
    }

    /// Downloads the list of all Pokemon names with their URLs.
    /// - Returns: A dictionary where the key is a Pokemon name and the value is
    ///   the corresponding API URL.
    func fetchPokemonNameMap() async throws -> [String: URL] {
        let listURL = baseURL
            .appendingPathComponent("pokemon")
            .appending(queryItems: [URLQueryItem(name: "limit", value: "100000")])
        let data = try await fetchData(from: listURL)
        let list = try JSONDecoder().decode(PokemonListResponse.self, from: data)
        var map: [String: URL] = [:]
        for item in list.results {
            map[item.name] = item.url
        }
        return map
    }

    func fetchPokemon(named name: String) async throws -> Pokemon {
        let detailURL = baseURL.appendingPathComponent("pokemon").appendingPathComponent(name)
        let speciesURL = baseURL.appendingPathComponent("pokemon-species").appendingPathComponent(name)
        async let detailData = fetchData(from: detailURL)
        async let speciesData = fetchData(from: speciesURL)
        let detailRaw = try await detailData
        let speciesRaw = try await speciesData
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

    private func fetchData(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return data
    }
}

private extension URL {
    func appending(queryItems: [URLQueryItem]) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        components.queryItems = (components.queryItems ?? []) + queryItems
        return components.url!
    }
}
