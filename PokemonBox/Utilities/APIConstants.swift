import Foundation

enum APIConstants {
    static let baseURL = URL(string: "https://pokeapi.co/api/v2")!

    enum Path {
        static let pokemonSpecies = "pokemon-species"
        static let pokemon = "pokemon"
        static let type = "type"
    }

    enum Query {
        static let limit = "limit"
        static let offset = "offset"
        static let limitValue = "100000"
    }

    enum Key {
        static let officialArtwork = "official-artwork"
    }
}
