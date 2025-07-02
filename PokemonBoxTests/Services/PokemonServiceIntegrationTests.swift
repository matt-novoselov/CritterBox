import Testing
import Foundation
@testable import PokemonBox

@Suite("PokemonService API Tests")
struct PokemonServiceIntegrationTests {
    let service = PokemonService()

    @Test("First page includes Bulbasaur")
    func firstPageTest() async throws {
        let page = try await service.fetchPokemonPage(limit: 1, offset: 0)
        #expect(page.items.count == 1)
        #expect(page.items.first?.name == "bulbasaur")
    }

    @Test("Offset loads Ivysaur")
    func offsetPageTest() async throws {
        let page = try await service.fetchPokemonPage(limit: 1, offset: 1)
        #expect(page.items.count == 1)
        #expect(page.items.first?.name == "ivysaur")
    }
    
    // Add more tests for pagination

    @Test("Name set contains Pikachu")
    func nameSetTest() async throws {
        let names = try await service.fetchPokemonNameSet()
        #expect(names.contains("pikachu"))
    }
    
    // Add more tests for non existing

    @Test("Type map contains Pikachu under electric")
    func typeMapTest() async throws {
        let map = try await service.fetchPokemonTypeMap()
        let electric = map["electric"] ?? []
        #expect(electric.contains("pikachu"))
    }
    
    // Add more tests for type search:
        // Search more
        // Search for pokemons if they have multiple types
        // Search for nonexisting type

    @Test("Fetching nonexistent pokemon throws")
    func invalidPokemonTest() async {
        do {
            _ = try await service.fetchPokemon(named: "notapokemon")
        } catch {
            #expect(error is URLError)
        }
    }
    
    // Test that fetchPokemonPage for x returns x items in array
    
    // Test that fetchPokemon is skipped if         // Skip forms by reloading canonical species if needed
//    if detail.name != detail.species.name {
//        return try await fetchPokemon(named: detail.species.name)
//    }
    
    // Test that fetchPokemon flavor is trimmed to one sentences if amount of sentences is > 1
}
