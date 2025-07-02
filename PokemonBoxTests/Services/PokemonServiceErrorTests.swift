import Testing
import Foundation
@testable import PokemonBox

@Suite("PokemonService Error Tests")
struct PokemonServiceErrorTests {
    @Test("Name set throws on bad response")
    func nameSetError() async {
        let url = apiURL(APIConstants.Path.pokemonSpecies, queryItems: [URLQueryItem(name: APIConstants.Query.limit, value: APIConstants.Query.limitValue)])
        let session = MockURLSession(responses: [url: (Data(), 500)])
        let service = PokemonService(session: session)
        do {
            _ = try await service.fetchPokemonNameSet()
            #expect(false)
        } catch {
            #expect(error is URLError)
        }
    }

    @Test("Type map throws when detail fails")
    func typeMapDetailError() async {
        let listURL = apiURL(APIConstants.Path.type)
        let detailURL = URL(string: "https://pokeapi.co/api/v2/type/grass/")!
        let list = "{\"results\":[{\"name\":\"grass\",\"url\":\"https://pokeapi.co/api/v2/type/grass/\"}]}".data(using: .utf8)!
        let session = MockURLSession(responses: [listURL: (list, 200), detailURL: (Data(), 500)])
        let service = PokemonService(session: session)
        do {
            _ = try await service.fetchPokemonTypeMap()
            #expect(false)
        } catch {
            #expect(error is URLError)
        }
    }

    @Test("Fetch pokemon throws on bad status")
    func fetchPokemonError() async {
        let url = apiURL("pokemon/bad")
        let session = MockURLSession(responses: [url: (Data(), 404)])
        let service = PokemonService(session: session)
        do {
            _ = try await service.fetchPokemon(named: "bad")
            #expect(false)
        } catch {
            #expect(error is URLError)
        }
    }
}
