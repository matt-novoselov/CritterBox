//
//  MainPageViewController+Bindings.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 05/07/25.
//

import UIKit

extension MainPageViewController {
    @objc func didPullToRefresh() {
        refreshControl.beginRefreshing()
        viewModel.refresh()
    }

    /// Sets up bindings between the view and the view model.
    func bindViewModel() {
        viewModel.onPokemonsChange = { [weak self] items in
            DispatchQueue.main.async {
                self?.pokemons = items
                self?.pokemonTableView.reloadData()
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
        loadingFooter.frame.size.width = pokemonTableView.frame.width
        pokemonTableView.tableFooterView = loadingFooter
        loadingSpinner.startAnimating()
    }

    func hideLoadingFooter() {
        loadingSpinner.stopAnimating()
        pokemonTableView.tableFooterView = UIView(frame: .zero)
    }
}
