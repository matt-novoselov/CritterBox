import Testing
import Foundation
import UIKit
@testable import PokemonBox

@Suite("ImageCache Tests")
struct ImageCacheTests {

    @Test("image(for:) returns nil when no image has been inserted")
    func returnsNilWhenMissing() {
        let url = URL(string: "https://example.com/missing")!
        #expect(ImageCache.shared.image(for: url) == nil)
    }

    @Test("insertImage(_:for:) stores and retrieves the image for the given URL")
    func insertAndRetrieve() {
        let url = URL(string: "https://example.com/insert")!
        let image = UIImage()
        ImageCache.shared.insertImage(image, for: url)
        #expect(ImageCache.shared.image(for: url) === image)
    }

    @Test("inserting an image for one URL does not affect other URLs")
    func isolationBetweenURLs() {
        let url1 = URL(string: "https://example.com/url1")!
        let url2 = URL(string: "https://example.com/url2")!
        let image = UIImage()
        ImageCache.shared.insertImage(image, for: url1)
        #expect(ImageCache.shared.image(for: url2) == nil)
    }
}
