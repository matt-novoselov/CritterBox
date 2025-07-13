//
//  MainPageViewController+Layout.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 05/07/25.
//

import UIKit

extension MainPageViewController {

    // MARK: - Public API

    /// Configures all UI components for the main page.
    /// This is a convenience method that calls all other setup methods in this extension.
    func setupLayout() {
        setupNavigationBar()
        setupTableView()
        setupUnavailableView()
    }

    /// Configures navigation bar title and search controller.
    func setupNavigationBar() {
        setupTitleView()
        setupSearchController()
    }

    /// Sets up the table view, refresh control, and loading footer.
    func setupTableView() {
        configureTableView()
        setupRefreshControl()
        setupLoadingFooter()
        addTableViewToViewHierarchy()
    }

    /// Configures the unavailable (empty-state) view.
    func setupUnavailableView() {
        unavailableView.isHidden = true
        unavailableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(unavailableView)
        NSLayoutConstraint.activate([
            unavailableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            unavailableView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            unavailableView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: Layout.horizontalInset),
            unavailableView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -Layout.horizontalInset)
        ])
    }

    // MARK: - Private Helpers

    private func setupTitleView() {
        navigationItem.titleView = TitleView()
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search name or type"
        searchController.obscuresBackgroundDuringPresentation = false

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func configureTableView() {
        pokemonTableView.dataSource = self
        pokemonTableView.delegate = self
        pokemonTableView.register(PokemonCell.self, forCellReuseIdentifier: PokemonCell.reuseIdentifier)

        pokemonTableView.refreshControl = refreshControl
        pokemonTableView.allowsSelection = false
        pokemonTableView.showsVerticalScrollIndicator = false

        pokemonTableView.tableHeaderView = UIView(frame: .zero)
        pokemonTableView.tableFooterView = UIView(frame: .zero)
        pokemonTableView.separatorInset = UIEdgeInsets(top: 0, left: Layout.horizontalInset, bottom: 0, right: Layout.horizontalInset)
    }

    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }

    private func setupLoadingFooter() {
        loadingFooter.frame.size.height = 44
        loadingFooter.addSubview(loadingSpinner)

        loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingSpinner.centerXAnchor.constraint(equalTo: loadingFooter.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: loadingFooter.centerYAnchor)
        ])
    }

    private func addTableViewToViewHierarchy() {
        pokemonTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pokemonTableView)

        NSLayoutConstraint.activate([
            pokemonTableView.topAnchor.constraint(equalTo: view.topAnchor),
            pokemonTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pokemonTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pokemonTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
