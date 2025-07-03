//
//  MainPageViewController+Search.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 05/07/25.
//

import UIKit

// MARK: - UISearchResultsUpdating
extension MainPageViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.updateSearch(text: searchController.searchBar.text ?? "")
    }
}

extension MainPageViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.updateSearch(text: "")
    }
}
