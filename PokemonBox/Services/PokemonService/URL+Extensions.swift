//
//  URL+Extensions.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 03/07/25.
//

import Foundation

/// Helper to append query parameters to a URL.
private extension URL {
    func appending(queryItems: [URLQueryItem]) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        components.queryItems = (components.queryItems ?? []) + queryItems
        return components.url!
    }
}
