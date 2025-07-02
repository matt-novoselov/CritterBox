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

    @Test("Pagination returns requested number of items")
    func paginationCountTest() async throws {
        let limit = 3
        let page = try await service.fetchPokemonPage(limit: limit, offset: 0)
        #expect(page.items.count == limit)
        let names = page.items.map { $0.name }
        #expect(names == ["bulbasaur", "ivysaur", "venusaur"])
    }

    @Test("Pagination with offset skips previous items")
    func paginationOffsetTest() async throws {
        let page = try await service.fetchPokemonPage(limit: 2, offset: 2)
        #expect(page.items.count == 2)
        let names = page.items.map { $0.name }
        #expect(names.first == "venusaur")
        #expect(names.last == "charmander")
    }

    @Test("Name set contains Pikachu")
    func nameSetTest() async throws {
        let names = try await service.fetchPokemonNameSet()
        #expect(names.contains("pikachu"))
    }

    @Test("Name set does not contain invalid name")
    func nameSetInvalidTest() async throws {
        let names = try await service.fetchPokemonNameSet()
        #expect(!names.contains("notapokemon"))
    }

    @Test("Type map contains Pikachu under electric")
    func typeMapTest() async throws {
        let map = try await service.fetchPokemonTypeMap()
        let electric = map["electric"] ?? []
        #expect(electric.contains("pikachu"))
    }

    @Test("Type map includes multi type pokemon")
    func multiTypeTest() async throws {
        let map = try await service.fetchPokemonTypeMap()
        let fire = map["fire"] ?? []
        let flying = map["flying"] ?? []
        #expect(fire.contains("charizard"))
        #expect(flying.contains("charizard"))
    }

    @Test("Type map missing invalid type")
    func invalidTypeTest() async throws {
        let map = try await service.fetchPokemonTypeMap()
        #expect(map["notatype"] == nil)
    }

    @Test("Fetching nonexistent pokemon throws")
    func invalidPokemonTest() async {
        do {
            _ = try await service.fetchPokemon(named: "notapokemon")
        } catch {
            #expect(error is URLError)
        }
    }

    @Test("Canonical species returned for forms")
    func canonicalFormTest() async throws {
        let pokemon = try await service.fetchPokemon(named: "pikachu-rock-star")
        #expect(pokemon.name == "pikachu")
    }

    @Test("Flavor text trimmed to single sentence")
    func flavorTrimTest() async throws {
        let pokemon = try await service.fetchPokemon(named: "mewtwo")
        if let flavor = pokemon.flavorText {
            let parts = flavor.split(separator: ".", omittingEmptySubsequences: true)
            #expect(parts.count == 1)
        } else {
            #expect(false)
        }
    }
}
