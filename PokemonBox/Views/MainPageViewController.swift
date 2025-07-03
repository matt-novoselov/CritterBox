//
//  ViewController.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 01/07/25.
//

import UIKit

class MainPageViewController: UIViewController {
    private let viewModel = MainPageViewModel()
    private var pokemons = [Pokemon]()
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

        titleStack.isAccessibilityElement = true
        titleStack.accessibilityTraits = .header
        titleStack.accessibilityLabel = "Pokemonbox"
        pokemonLabel.isAccessibilityElement = false
        boxLabel.isAccessibilityElement = false
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
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
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

        bindViewModel()
        viewModel.refresh()
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
            viewModel.loadNextPage()
        }
    }
}

extension MainPageViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.updateSearch(text: searchController.searchBar.text ?? "")
    }
}

private extension MainPageViewController {
    @objc func didPullToRefresh() {
        refreshControl.beginRefreshing()
        viewModel.refresh()
    }

    func bindViewModel() {
        viewModel.onPokemonsChange = { [weak self] items in
            DispatchQueue.main.async {
                self?.pokemons = items
                self?.tableView.reloadData()
            }
        }

        viewModel.onLoadingChange = { [weak self] loading in
            DispatchQueue.main.async {
                if loading {
                    if !(self?.refreshControl.isRefreshing ?? false) {
                        self?.showLoadingFooter()
                    }
                } else {
                    self?.hideLoadingFooter()
                    if self?.refreshControl.isRefreshing ?? false {
                        self?.refreshControl.endRefreshing()
                    }
                }
            }
        }

        viewModel.onEmptyStateChange = { [weak self] empty in
            DispatchQueue.main.async {
                self?.unavailableView.isHidden = !empty
            }
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
        viewModel.updateSearch(text: "")
    }
}
