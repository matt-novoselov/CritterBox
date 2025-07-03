//
//  MainPageViewController+Layout.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 05/07/25.
//

import UIKit

extension MainPageViewController {
    /// Configures navigation bar title and search controller.
    func setupNavigationBar() {
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
        titleStack.accessibilityLabel = "PokemonBox"
        pokemonLabel.isAccessibilityElement = false
        boxLabel.isAccessibilityElement = false

        searchController.searchBar.placeholder = "Search name or type"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
    }

    /// Sets up the table view, refresh control, and loading footer.
    func setupTableView() {
        pokemonTableView.translatesAutoresizingMaskIntoConstraints = false
        pokemonTableView.dataSource = self
        pokemonTableView.delegate = self
        pokemonTableView.register(PokemonCell.self,
                                  forCellReuseIdentifier: PokemonCell.reuseIdentifier)
        pokemonTableView.refreshControl = refreshControl
        pokemonTableView.allowsSelection = false
        pokemonTableView.showsVerticalScrollIndicator = false
        pokemonTableView.tableHeaderView = UIView(frame: .zero)

        loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        loadingFooter.addSubview(loadingSpinner)
        NSLayoutConstraint.activate([
            loadingSpinner.centerXAnchor.constraint(equalTo: loadingFooter.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: loadingFooter.centerYAnchor)
        ])
        loadingFooter.frame.size.height = 44
        pokemonTableView.tableFooterView = UIView(frame: .zero)

        refreshControl.addTarget(self,
                                 action: #selector(didPullToRefresh),
                                 for: .valueChanged)

        view.addSubview(pokemonTableView)
        NSLayoutConstraint.activate([
            pokemonTableView.topAnchor.constraint(equalTo: view.topAnchor),
            pokemonTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pokemonTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.horizontalInset),
            pokemonTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.horizontalInset)
        ])
    }

    /// Configures the unavailable (empty-state) view.
    func setupUnavailableView() {
        unavailableView.isHidden = true
        view.addSubview(unavailableView)
        NSLayoutConstraint.activate([
            unavailableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            unavailableView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            unavailableView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            unavailableView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])
    }
}
