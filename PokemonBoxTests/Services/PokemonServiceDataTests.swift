import Testing
import Foundation
@testable import PokemonBox

@Suite("PokemonService Data Tests")
struct PokemonServiceDataTests {
    func makeService() -> (PokemonService, MockURLSession) {
        // prepare stub data
        var responses: [URL: (Data, Int)] = [:]

        // Page list with two pokemon
        let pageURL = apiURL(APIConstants.Path.pokemonSpecies, queryItems: [
            URLQueryItem(name: APIConstants.Query.limit, value: "2"),
            URLQueryItem(name: APIConstants.Query.offset, value: "0")
        ])
        let pageJSON = """
        {
            "count": 2,
            "next": null,
            "previous": null,
            "results": [
                {"name": "bulbasaur", "url": "https://pokeapi.co/api/v2/pokemon/1/"},
                {"name": "charmander", "url": "https://pokeapi.co/api/v2/pokemon/4/"}
            ]
        }
        """.data(using: .utf8)!
        responses[pageURL] = (pageJSON, 200)

        // bulbasaur detail
        let bulbaURL = apiURL("pokemon/bulbasaur")
        let bulbaDetail = """
        {
            "name": "bulbasaur",
            "types": [{"type": {"name": "grass"}}, {"type": {"name": "poison"}}],
            "species": {"name": "bulbasaur", "url": "https://pokeapi.co/api/v2/pokemon-species/1/"},
            "sprites": {"other": {"official-artwork": {"front_default": "https://example.com/bulba.png"}}}
        }
        """.data(using: .utf8)!
        responses[bulbaURL] = (bulbaDetail, 200)

        // charmander detail
        let charURL = apiURL("pokemon/charmander")
        let charDetail = """
        {
            "name": "charmander",
            "types": [{"type": {"name": "fire"}}],
            "species": {"name": "charmander", "url": "https://pokeapi.co/api/v2/pokemon-species/4/"},
            "sprites": {"other": {"official-artwork": {"front_default": null}}}
        }
        """.data(using: .utf8)!
        responses[charURL] = (charDetail, 200)

        // species
        let bulbaSpeciesURL = URL(string: "https://pokeapi.co/api/v2/pokemon-species/1/")!
        let speciesBulba = """
        {"flavor_text_entries": [{"flavor_text": "Seed", "language": {"name": "en"}}]}
        """.data(using: .utf8)!
        responses[bulbaSpeciesURL] = (speciesBulba, 200)

        let charSpeciesURL = URL(string: "https://pokeapi.co/api/v2/pokemon-species/4/")!
        let speciesChar = """
        {"flavor_text_entries": []}
        """.data(using: .utf8)!
        responses[charSpeciesURL] = (speciesChar, 200)

        // name set
        let nameSetURL = apiURL(APIConstants.Path.pokemonSpecies, queryItems: [URLQueryItem(name: APIConstants.Query.limit, value: APIConstants.Query.limitValue)])
        responses[nameSetURL] = (pageJSON, 200)

        // type list
        let typeListURL = apiURL(APIConstants.Path.type)
        let typeList = """
        {"results": [
            {"name": "grass", "url": "https://pokeapi.co/api/v2/type/grass/"},
            {"name": "fire", "url": "https://pokeapi.co/api/v2/type/fire/"}
        ]}
        """.data(using: .utf8)!
        responses[typeListURL] = (typeList, 200)

        // type details
        let grassURL = URL(string: "https://pokeapi.co/api/v2/type/grass/")!
        let grassDetail = """
        {"pokemon": [{"pokemon": {"name": "bulbasaur"}}]}
        """.data(using: .utf8)!
        responses[grassURL] = (grassDetail, 200)

        let fireURL = URL(string: "https://pokeapi.co/api/v2/type/fire/")!
        let fireDetail = """
        {"pokemon": [{"pokemon": {"name": "charmander"}}]}
        """.data(using: .utf8)!
        responses[fireURL] = (fireDetail, 200)

        // redirect form detail
        let redirectURL = apiURL("pokemon/bulbasaur-red")
        let redirectDetail = """
        {
            "name": "bulbasaur-red",
            "types": [],
            "species": {"name": "bulbasaur", "url": "https://pokeapi.co/api/v2/pokemon-species/1/"},
            "sprites": {"other": {"official-artwork": {"front_default": null}}}
        }
        """.data(using: .utf8)!
        responses[redirectURL] = (redirectDetail, 200)

        let session = MockURLSession(responses: responses)
        let service = PokemonService(session: session)
        return (service, session)
    }

    @Test("Fetch pokemon page")
    func fetchPokemonPageTest() async throws {
        let (service, session) = makeService()
        let page = try await service.fetchPokemonPage(limit: 2, offset: 0)
        #expect(page.totalCount == 2)
        #expect(page.items.count == 2)
        #expect(page.items.first?.name == "bulbasaur")
        #expect(session.callCount[apiURL(APIConstants.Path.pokemonSpecies, queryItems: [URLQueryItem(name: APIConstants.Query.limit, value: "2"), URLQueryItem(name: APIConstants.Query.offset, value: "0")])] == 1)
    }

    @Test("Fetch pokemon name set")
    func fetchPokemonNameSetTest() async throws {
        let (service, _) = makeService()
        let names = try await service.fetchPokemonNameSet()
        #expect(names == ["bulbasaur", "charmander"])
    }

    @Test("Fetch pokemon type map")
    func fetchPokemonTypeMapTest() async throws {
        let (service, _) = makeService()
        let map = try await service.fetchPokemonTypeMap()
        #expect(map["grass"] == ["bulbasaur"])
        #expect(map["fire"] == ["charmander"])
    }

    @Test("Redirect form loads canonical pokemon")
    func fetchPokemonRedirectTest() async throws {
        let (service, _) = makeService()
        let p = try await service.fetchPokemon(named: "bulbasaur-red")
        #expect(p.name == "bulbasaur")
    }

    @Test("Uses cache for repeated requests")
    func fetchPokemonCacheTest() async throws {
        let (service, session) = makeService()
        _ = try await service.fetchPokemon(named: "bulbasaur")
        _ = try await service.fetchPokemon(named: "bulbasaur")
        let url = apiURL("pokemon/bulbasaur")
        #expect(session.callCount[url] == 1)
    }
}
