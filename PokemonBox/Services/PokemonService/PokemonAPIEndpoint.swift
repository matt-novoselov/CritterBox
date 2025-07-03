//
//  PokemonAPIEndpoint.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 03/07/25.
//

import Foundation


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
                    URLQueryItem(name: APIConstants.Query.limit, value: APIConstants.Query.limitValue)
                ])
        case .pokemonDetail(let name):
            return APIConstants.baseURL
                .appendingPathComponent(APIConstants.Path.pokemon)
                .appendingPathComponent(name)
        case .speciesDetail(let url):
            return url
        case .typeList:
            return APIConstants.baseURL.appendingPathComponent(APIConstants.Path.type)
        case .typeDetail(let url):
            return url
        }
    }
}
