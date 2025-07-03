//
//  MainPageViewModel+Paging.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 05/07/25.
//

import Foundation

extension MainPageViewModel {
    /// Loads the next page of results (either normal paging or search results).
    func loadNextPage() {
        guard !isLoading else { return }
        isLoading = true
        Task {
            do {
                if currentSearchText.isEmpty {
                    try await loadNormalPage()
                } else {
                    try await loadSearchPage()
                }
            } catch {
                print("Failed to fetch pokemons: \(error)")
            }
            isLoading = false
        }
    }

    func loadNormalPage() async throws {
        let offset = pokemons.count
        let page = try await service.fetchPokemonPage(limit: pageSize, offset: offset)
        if totalCount == nil {
            totalCount = page.totalCount
        }
        pokemons += page.items
    }
}
