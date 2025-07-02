import Foundation

final class MockURLSession: URLSession {
    private let responses: [URL: (Data, Int)]
    private(set) var callCount: [URL: Int] = [:]

    init(responses: [URL: (Data, Int)]) {
        self.responses = responses
    }

    override func data(from url: URL, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
        callCount[url, default: 0] += 1
        guard let (data, status) = responses[url] else {
            throw URLError(.badURL)
        }
        let response = HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil)!
        return (data, response)
    }
}
