//
//  ViewController.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 01/07/25.
//

import Foundation

/// Constants for building requests to the PokeAPI.
/// Strings used here are collected in ``PokemonAPIConstants`` for type safety.


/// A service layer for fetching Pokémon data from the PokéAPI.
/// Wraps URLSession and provides paging, detail, name‑set, and type‑map methods.
/// A service layer for fetching Pokémon data from the PokéAPI.
/// Wraps URLSession to expose paging, name‑set, type‑map, and detail APIs.
class PokemonService {
    let session: URLSession
    let cache = NSCache<NSURL, NSData>()

    init(session: URLSession = .shared) {
        self.session = session
    }
}
