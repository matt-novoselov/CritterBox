//
//  PokemonService.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 01/07/25.
//

import Foundation

/// A service that interacts with the PokéAPI to fetch Pokémon data.
///
/// This class provides methods for fetching lists of Pokémon with pagination,
/// retrieving detailed information for a specific Pokémon, and obtaining
/// collections of all Pokémon names and their associated types.
/// It also includes a simple caching mechanism to reduce network requests.
class PokemonService {
    let session: URLSession
    let cache = NSCache<NSURL, NSData>()

    init(session: URLSession = .shared) {
        self.session = session
    }
}
