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
