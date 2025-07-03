//
//  MainPageViewModel.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 05/07/25.
//

import Foundation

/// ViewModel for the main Pokémon list screen. Handles paging, search, and empty/loading state.
final class MainPageViewModel {
    private let service: PokemonService
    private let pageSize: Int

    private var totalCount: Int?
    private var nameSet = Set<String>()
    private var typeMap = [String: [String]]()
    private var filteredNames = [String]()
    private var searchOffset = 0
    private var currentSearchText = ""

    private(set) var pokemons = [Pokemon]() {
        didSet { onPokemonsChange?(pokemons) }
    }

    private(set) var isLoading = false {
        didSet { onLoadingChange?(isLoading) }
    }

    private(set) var isEmptyState = false {
        didSet { onEmptyStateChange?(isEmptyState) }
    }

    /// Called when the list of Pokémon changes.
    var onPokemonsChange: (([Pokemon]) -> Void)?
    /// Called when the loading state changes.
    var onLoadingChange: ((Bool) -> Void)?
    /// Called when the empty-state (no results) state changes.
    var onEmptyStateChange: ((Bool) -> Void)?

    init(service: PokemonService = PokemonService(), pageSize: Int = AppConstants.pageLimit) {
        self.service = service
        self.pageSize = pageSize
        Task {
            do {
                async let names = service.fetchPokemonNameSet()
                async let types = service.fetchPokemonTypeMap()
                nameSet = try await names
                typeMap = try await types
            } catch {
                print("Failed to prefetch names or types: \(error)")
            }
        }
    }

    /// Resets state and loads the first page.
    func refresh() {
        totalCount = nil
        pokemons = []
        searchOffset = 0
        filteredNames.removeAll()
        currentSearchText = ""
        isEmptyState = false
        loadNextPage()
    }

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

    private func loadNormalPage() async throws {
        let offset = pokemons.count
        let page = try await service.fetchPokemonPage(limit: pageSize, offset: offset)
        if totalCount == nil {
            totalCount = page.totalCount
        }
        pokemons += page.items
    }

    private func loadSearchPage() async throws {
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
