import Testing
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

    @Test("Name set contains Pikachu")
    func nameSetTest() async throws {
        let names = try await service.fetchPokemonNameSet()
        #expect(names.contains("pikachu"))
    }

    @Test("Type map contains Pikachu under electric")
    func typeMapTest() async throws {
        let map = try await service.fetchPokemonTypeMap()
        let electric = map["electric"] ?? []
        #expect(electric.contains("pikachu"))
    }

    @Test("Form redirects to canonical Pokemon")
    func redirectFormTest() async throws {
        let pokemon = try await service.fetchPokemon(named: "pikachu-rock-star")
        #expect(pokemon.name == "pikachu")
    }

    @Test("Fetching nonexistent pokemon throws")
    func invalidPokemonTest() async {
        do {
            _ = try await service.fetchPokemon(named: "notapokemon")
            #expect(false)
        } catch {
            #expect(error is URLError)
        }
    }
}
