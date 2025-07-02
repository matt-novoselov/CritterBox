//
//  ViewController.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 01/07/25.
//

import UIKit

fileprivate let pageSize = 20

class MainPageViewController: UIViewController {

    private var pokemons = [Pokemon]()
    private var totalCount: Int?
    private var isLoading = false
    private var pokemonNameMap = Set<String>()
    private var pokemonTypeMap = [String: [String]]()
    private var filteredNames = [String]()
    private var searchOffset = 0
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let searchController = UISearchController(searchResultsController: nil)
    private let unavailableView = UnavailableView()
    private let loadingFooter = UIView()
    private let loadingSpinner = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // Custom title with mixed font weights
        let pokemonLabel = UILabel()
        pokemonLabel.text = "Pokemon"
        pokemonLabel.font = UIFont.bricolageGrotesque(ofSize: 26, weight: .regular)
        let boxLabel = UILabel()
        boxLabel.text = "Box"
        boxLabel.font = UIFont.bricolageGrotesque(ofSize: 26, weight: .bold)

        let titleStack = UIStackView(arrangedSubviews: [pokemonLabel, boxLabel])
        navigationItem.titleView = titleStack
        searchController.searchBar.placeholder = "Search name or type"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PokemonCell.self, forCellReuseIdentifier: PokemonCell.reuseIdentifier)
        tableView.refreshControl = refreshControl
        tableView.allowsSelection = false
        tableView.showsVerticalScrollIndicator = false
        tableView.tableHeaderView = UIView(frame: .zero)
        loadingSpinner.hidesWhenStopped = true
        loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        loadingFooter.addSubview(loadingSpinner)
        NSLayoutConstraint.activate([
            loadingSpinner.centerXAnchor.constraint(equalTo: loadingFooter.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: loadingFooter.centerYAnchor)
        ])
        loadingFooter.frame.size.height = 44
        tableView.tableFooterView = UIView(frame: .zero)
        refreshControl.addTarget(self, action: #selector(refreshPokemons), for: .valueChanged)
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        unavailableView.isHidden = true
        unavailableView.configure(title: "No Pokémon Found!", message: "Looks like even the tall grass is empty. Try another search.")
        view.addSubview(unavailableView)
        NSLayoutConstraint.activate([
            unavailableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            unavailableView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            unavailableView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            unavailableView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])

        Task {
            do {
                let service = PokemonService()
                async let names = service.fetchPokemonNameSet()
                async let types = service.fetchPokemonTypeMap()
                pokemonNameMap = try await names
                pokemonTypeMap = try await types
            } catch {
                print("Failed to prefetch names or types: \(error)")
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
        } else {
            showLoadingFooter()
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
            hideLoadingFooter()
            if reset {
                refreshControl.endRefreshing()
            }
        }
    }
}

extension MainPageViewController: UITableViewDataSource {
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

extension MainPageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
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

extension MainPageViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.lowercased(), !text.isEmpty else {
            if !filteredNames.isEmpty {
                cancelSearch()
            }
            unavailableView.isHidden = true
            return
        }
        let matchedTypeNames = pokemonTypeMap
            .filter { $0.key.localizedCaseInsensitiveContains(text) }
            .flatMap { $0.value }
        let validTypeNames = matchedTypeNames.filter { pokemonNameMap.contains($0) }
        if validTypeNames.isEmpty {
            filteredNames = pokemonNameMap.filter { $0.localizedCaseInsensitiveContains(text) }
        } else {
            filteredNames = Array(Set(validTypeNames))
        }
        searchOffset = 0
        pokemons.removeAll()
        tableView.reloadData()
        if filteredNames.isEmpty {
            unavailableView.isHidden = false
        } else {
            unavailableView.isHidden = true
            loadNextSearchPage()
        }
    }
}

private extension MainPageViewController {
    func cancelSearch() {
        filteredNames.removeAll()
        searchOffset = 0
        loadNextPage(reset: true)
        unavailableView.isHidden = true
    }

    func loadNextSearchPage() {
        guard !isLoading, searchOffset < filteredNames.count else { return }
        isLoading = true
        showLoadingFooter()
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
                unavailableView.isHidden = pokemons.isEmpty ? false : true
            } catch {
                print("Failed to fetch search results: \(error) for \(names)")
            }
            isLoading = false
            hideLoadingFooter()
        }
    }

    func showLoadingFooter() {
        loadingFooter.frame.size.width = tableView.frame.width
        tableView.tableFooterView = loadingFooter
        loadingSpinner.startAnimating()
    }

    func hideLoadingFooter() {
        loadingSpinner.stopAnimating()
        tableView.tableFooterView = UIView(frame: .zero)
    }
}

extension MainPageViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        cancelSearch()
    }
}
