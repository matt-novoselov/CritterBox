//
//  MainPageViewController.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 01/07/25.
//

import UIKit

class MainPageViewController: UIViewController {
    let viewModel = MainPageViewModel()
    var pokemons = [Pokemon]()
    let pokemonTableView = UITableView()
    let refreshControl = UIRefreshControl()
    let searchController = UISearchController(searchResultsController: nil)
    let unavailableView = UnavailableView()
    let loadingFooter = UIView()
    let loadingSpinner = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupNavigationBar()
        setupTableView()
        setupUnavailableView()
        bindViewModel()
        viewModel.refresh()
    }
}
