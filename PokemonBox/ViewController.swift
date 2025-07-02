//
//  ViewController.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 01/07/25.
//

import UIKit

class ViewController: UIViewController {

    private var pokemons: [Pokemon] = []
    private var searchResults: [Pokemon] = []
    private var allPokemons: [Pokemon]?
    private var allPokemonsTask: Task<[Pokemon], Error>?
    private var searchTask: Task<Void, Never>?
    private var totalCount: Int?
    private var isLoading = false
    private let pageSize = 20
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let searchController = UISearchController(searchResultsController: nil)

    private var isSearchActive: Bool {
        searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        navigationItem.title = "PokemonBox"

        // Custom title with mixed font weights
        let pokemonLabel = UILabel()
        pokemonLabel.text = "Pokemon"
        pokemonLabel.font = UIFont.bricolageGrotesque(ofSize: 26, weight: .regular)
        let boxLabel = UILabel()
        boxLabel.text = "Box"
        boxLabel.font = UIFont.bricolageGrotesque(ofSize: 26, weight: .bold)

        let titleStack = UIStackView(arrangedSubviews: [pokemonLabel, boxLabel])
        titleStack.axis = .horizontal
        titleStack.spacing = 0
        titleStack.alignment = .center
        navigationItem.titleView = titleStack
        searchController.searchBar.placeholder = "Search name or type"
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PokemonCell.self, forCellReuseIdentifier: PokemonCell.reuseIdentifier)
        tableView.refreshControl = refreshControl
        tableView.allowsSelection = false
        tableView.showsVerticalScrollIndicator = false
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.tableFooterView = UIView(frame: .zero)
        refreshControl.addTarget(self, action: #selector(refreshPokemons), for: .valueChanged)
        tableView.contentInset.top = 16
        tableView.contentInset.bottom = 16
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        loadNextPage(reset: true)
    }

    @objc private func refreshPokemons() {
        loadNextPage(reset: true)
    }

    private func loadNextPage(reset: Bool = false) {
        guard !isLoading else { return }
        isLoading = true
        if reset {
            totalCount = nil
            pokemons.removeAll()
            tableView.reloadData()
        }
        Task {
            if reset {
                refreshControl.beginRefreshing()
            }
            do {
                let service = PokemonService()
                let page = try await service.fetchPokemonPage(limit: pageSize, offset: pokemons.count)
                if totalCount == nil {
                    totalCount = page.totalCount
                }
                pokemons += page.items
                tableView.reloadData()
                updateBackgroundView()
            } catch {
                print("Failed to fetch pokemons: \(error)")
            }
            isLoading = false
            if reset {
                refreshControl.endRefreshing()
            }
        }
    }

    private func updateBackgroundView() {
        if isSearchActive && searchResults.isEmpty {
            var config = UIContentUnavailableConfiguration.search()
            config.text = "No Pokémon Found"
            tableView.backgroundView = UIContentUnavailableView(configuration: config)
        } else {
            tableView.backgroundView = nil
        }
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return (isSearchActive ? searchResults : pokemons).count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PokemonCell.reuseIdentifier, for: indexPath) as! PokemonCell
        let data = isSearchActive ? searchResults : pokemons
        cell.configure(with: data[indexPath.section])
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !isSearchActive else { return }
        if indexPath.section == pokemons.count - 4 {
            if let total = totalCount {
                if pokemons.count < total {
                    loadNextPage()
                }
            } else {
                loadNextPage()
            }
        }
    }
}

extension ViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text?.lowercased() else { return }
        guard !query.isEmpty else {
            searchResults.removeAll()
            updateBackgroundView()
            tableView.reloadData()
            return
        }

        searchTask?.cancel()
        searchTask = Task { [weak self] in
            guard let self else { return }

            if self.allPokemons == nil {
                if self.allPokemonsTask == nil {
                    self.allPokemonsTask = Task {
                        try await PokemonService().fetchAllPokemon()
                    }
                }

                do {
                    self.allPokemons = try await self.allPokemonsTask!.value
                } catch {
                    if (error as? URLError)?.code != .cancelled {
                        print("Failed to fetch all pokemons: \(error)")
                    }
                    return
                }
            }

            guard let all = self.allPokemons else { return }
            let results = all.filter { pokemon in
                pokemon.name.lowercased().contains(query) ||
                pokemon.types.contains(where: { $0.lowercased().contains(query) })
            }

            await MainActor.run {
                self.searchResults = results
                self.tableView.reloadData()
                self.updateBackgroundView()
            }
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchTask?.cancel()
        searchResults.removeAll()
        updateBackgroundView()
        tableView.reloadData()
    }
}

