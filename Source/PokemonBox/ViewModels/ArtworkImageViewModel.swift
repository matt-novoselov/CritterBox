import UIKit

/// ViewModel responsible for fetching and caching artwork images.
final class ArtworkImageViewModel {
    private var loadTask: Task<Void, Never>?

    /// Loads an image from the provided URL.
    /// - Parameters:
    ///   - url: The image URL.
    ///   - completion: Called on the main thread with the loaded image.
    func load(url: URL?, completion: @escaping (UIImage?) -> Void) {
        loadTask?.cancel()
        guard let url = url else {
            completion(nil)
            return
        }
        if let cached = ImageCache.shared.image(for: url) {
            DispatchQueue.main.async {
                completion(cached)
            }
        } else {
            loadTask = Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    guard !Task.isCancelled else { return }
                    let image = UIImage(data: data)
                    if let image {
                        ImageCache.shared.insertImage(image, for: url)
                    }
                    await MainActor.run { completion(image) }
                } catch {
                    await MainActor.run { completion(nil) }
                    guard let urlError = error as? URLError else {
                        print("Unknown artwork loading error: \(error)")
                        return
                    }
                    switch urlError.code {
                    case .cancelled:
                        print("Artwork loading cancelled.")
                    default:
                        print("Artwork loading error: \(error)")
                    }
                }
            }
        }
    }

    /// Cancels any ongoing image load.
    func cancel() {
        loadTask?.cancel()
    }
}
