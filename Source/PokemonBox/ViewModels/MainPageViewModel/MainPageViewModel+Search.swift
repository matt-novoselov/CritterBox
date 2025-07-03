//
//  MainPageViewModel+Search.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 05/07/25.
//

import Foundation

extension MainPageViewModel {
    /// Updates search text, resets paging, and triggers new fetch if needed.
    func updateSearch(text: String) {
        currentSearchText = text.lowercased()
        guard !currentSearchText.isEmpty else {
            isEmptyState = false
            pokemons = []
            loadNextPage()
            return
        }
        let matchedTypeNames = typeMap
            .filter { $0.key.localizedCaseInsensitiveContains(currentSearchText) }
            .flatMap { $0.value }
        let validTypeNames = matchedTypeNames.filter { nameSet.contains($0) }
        if validTypeNames.isEmpty {
            filteredNames = nameSet.filter { $0.localizedCaseInsensitiveContains(currentSearchText) }
        } else {
            filteredNames = Array(Set(validTypeNames))
        }
        searchOffset = 0
        pokemons = []
        if filteredNames.isEmpty {
            isEmptyState = true
        } else {
            isEmptyState = false
            loadNextPage()
        }
    }

    func loadSearchPage() async throws {
        guard searchOffset < filteredNames.count else { return }
        let slice = filteredNames[searchOffset..<min(searchOffset + pageSize, filteredNames.count)]
        searchOffset += slice.count
        let pagePokemons = try await withThrowingTaskGroup(of: Pokemon.self) { group -> [Pokemon] in
            for name in slice {
                group.addTask { try await self.service.fetchPokemon(named: name) }
            }
            var result = [Pokemon]()
            for try await p in group {
                result.append(p)
            }
            return result
        }
        pokemons += pagePokemons
        isEmptyState = pokemons.isEmpty
    }
}
