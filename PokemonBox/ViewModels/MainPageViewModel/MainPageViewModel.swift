//
//  MainPageViewModel.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 05/07/25.
//

import Foundation

/// ViewModel for the main Pokémon list screen. Handles paging, search, and empty/loading state.
final class MainPageViewModel {
    // MARK: - Dependencies
    let service: PokemonService
    let pageSize: Int

    // MARK: - State
    var totalCount: Int?
    var nameSet = Set<String>()
    var typeMap = [String: [String]]()
    var filteredNames = [String]()
    var searchOffset = 0
    var currentSearchText = ""

    var pokemons = [Pokemon]() {
        didSet { onPokemonsChange?(pokemons) }
    }

    var isLoading = false {
        didSet { onLoadingChange?(isLoading) }
    }

    var isEmptyState = false {
        didSet { onEmptyStateChange?(isEmptyState) }
    }

    // MARK: - Callbacks
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
}
