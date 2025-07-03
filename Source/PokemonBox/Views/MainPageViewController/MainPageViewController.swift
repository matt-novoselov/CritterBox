//
//  MainPageViewController.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 01/07/25.
//

import UIKit

// The main view controller for displaying the list of Pokémon.
class MainPageViewController: UIViewController {
    let viewModel = MainPageViewModel()
    var pokemons = [Pokemon]()
    let pokemonTableView = UITableView()
    let refreshControl = UIRefreshControl()
    let searchController = UISearchController(searchResultsController: nil)
    let unavailableView = UnavailableView(title: "No Pokémon Found!",
                                          message: "Looks like even the tall grass is empty. Try another search.")
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
