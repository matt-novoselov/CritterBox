//
//  ViewController.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 01/07/25.
//

import UIKit

class ViewController: UIViewController {

    private var pokemons: [Pokemon] = []
    private var totalCount: Int?
    private var isLoading = false
    private var pokemonNameMap: [String: URL] = [:]
    private var filteredNames: [String] = []
    private var searchOffset = 0
    private let pageSize = 20
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let searchController = UISearchController(searchResultsController: nil)

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
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self

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

        Task {
            do {
                let service = PokemonService()
                pokemonNameMap = try await service.fetchPokemonNameMap()
            } catch {
                print("Failed to prefetch names: \(error)")
            }
        }

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
            } catch {
                print("Failed to fetch pokemons: \(error)")
            }
            isLoading = false
            if reset {
                refreshControl.endRefreshing()
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return pokemons.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PokemonCell.reuseIdentifier, for: indexPath) as! PokemonCell
        cell.configure(with: pokemons[indexPath.section])
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
        if indexPath.section == pokemons.count - 4 {
            if searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true) {
                loadNextSearchPage()
            } else {
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
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.lowercased(), !text.isEmpty else {
            if !filteredNames.isEmpty {
                cancelSearch()
            }
            return
        }
        filteredNames = pokemonNameMap.keys.filter { $0.contains(text) }.sorted()
        searchOffset = 0
        pokemons.removeAll()
        tableView.reloadData()
        loadNextSearchPage()
    }
}

private extension ViewController {
    func cancelSearch() {
        filteredNames.removeAll()
        searchOffset = 0
        loadNextPage(reset: true)
    }

    func loadNextSearchPage() {
        guard !isLoading, searchOffset < filteredNames.count else { return }
        isLoading = true
        let names = filteredNames[searchOffset..<min(searchOffset + pageSize, filteredNames.count)]
        searchOffset += names.count
        Task {
            do {
                let service = PokemonService()
                let pagePokemons = try await withThrowingTaskGroup(of: Pokemon.self) { group in
                    for name in names {
                        group.addTask { try await service.fetchPokemon(named: name) }
                    }
                    var result: [Pokemon] = []
                    for try await pokemon in group {
                        result.append(pokemon)
                    }
                    return result
                }
                pokemons.append(contentsOf: pagePokemons)
                tableView.reloadData()
            } catch {
                print("Failed to fetch search results: \(error)")
            }
            isLoading = false
        }
    }
}

