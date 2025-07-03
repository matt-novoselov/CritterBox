//
//  PokemonServiceAPI.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 05/07/25.
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

/// All PokéAPI endpoints for building request URLs.
enum PokemonAPIEndpoint {
    case speciesList(limit: Int, offset: Int)
    case speciesListAll
    case pokemonDetail(name: String)
    case speciesDetail(url: URL)
    case typeList
    case typeDetail(url: URL)

    var url: URL {
        switch self {
        case .speciesList(let limit, let offset):
            return APIConstants.baseURL
                .appendingPathComponent(APIConstants.Path.pokemonSpecies)
                .appending(queryItems: [
                    URLQueryItem(name: APIConstants.Query.limit, value: String(limit)),
                    URLQueryItem(name: APIConstants.Query.offset, value: String(offset))
                ])
        case .speciesListAll:
            return APIConstants.baseURL
                .appendingPathComponent(APIConstants.Path.pokemonSpecies)
                .appending(queryItems: [
                    URLQueryItem(name: APIConstants.Query.limit, value: APIConstants.Query.limitValue.description)
                ])
        case .pokemonDetail(let name):
            return APIConstants.baseURL
                .appendingPathComponent(APIConstants.Path.pokemon)
                .appendingPathComponent(name)
        case .speciesDetail(let url), .typeDetail(let url):
            return url
        case .typeList:
            return APIConstants.baseURL.appendingPathComponent(APIConstants.Path.type)
        }
    }
}
