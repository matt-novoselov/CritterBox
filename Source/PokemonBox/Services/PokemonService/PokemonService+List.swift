//
//  PokemonService+List.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 05/07/25.
//

import Foundation

extension PokemonService {
    /// Fetches a page of Pokémon (species) and their details.
    func fetchPokemonPage(limit: Int = AppConstants.pageLimit,
                          offset: Int = 0) async throws -> PokemonPage {
        let list: PokemonListResponse = try await request(
            PokemonListResponse.self,
            from: .speciesList(limit: limit, offset: offset)
        )
        var items = [Pokemon]()
        for entry in list.results {
            let pokemon = try await fetchPokemon(named: entry.name)
            items.append(pokemon)
        }
        return PokemonPage(totalCount: list.count, items: items)
    }

    /// Fetches all Pokémon species names as a name set.
    func fetchPokemonNameSet() async throws -> Set<String> {
        let list: PokemonListResponse = try await request(
            PokemonListResponse.self,
            from: .speciesListAll
        )
        return Set(list.results.map { $0.name })
    }

    /// Fetches all Pokémon grouped by type name.
    func fetchPokemonTypeMap() async throws -> [String: Set<String>] {
        let list: PokemonTypeListResponse = try await request(
            PokemonTypeListResponse.self,
            from: .typeList
        )
        var map = [String: Set<String>]()
        try await withThrowingTaskGroup(of: (String, [String]).self) { group in
            for entry in list.results {
                group.addTask {
                    let detail: PokemonTypeDetailResponse = try await self.request(
                        PokemonTypeDetailResponse.self,
                        from: .typeDetail(url: entry.url)
                    )
                    let names = detail.pokemon.map { $0.pokemon.name }
                    return (entry.name, names)
                }
            }
            for try await (type, names) in group {
                map[type] = Set(names)
            }
        }
        return map
    }
}
