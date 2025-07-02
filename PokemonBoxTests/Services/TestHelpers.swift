import Foundation
@testable import PokemonBox

func apiURL(_ path: String, queryItems: [URLQueryItem] = []) -> URL {
    let base = APIConstants.baseURL.appendingPathComponent(path)
    var components = URLComponents(url: base, resolvingAgainstBaseURL: false)!
    components.queryItems = (components.queryItems ?? []) + queryItems
    return components.url!
}
