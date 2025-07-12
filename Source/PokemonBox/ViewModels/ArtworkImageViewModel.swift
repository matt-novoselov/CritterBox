import UIKit

/// ViewModel responsible for fetching and caching artwork images.
final class ArtworkImageViewModel {
    private var loadTask: Task<UIImage?, Never>?

    /// Loads an image asynchronously.
    /// - Parameter url: The image URL.
    /// - Returns: The loaded image, or nil on failure.
    func loadImage(from url: URL?) async -> UIImage? {
        loadTask?.cancel()

        guard let url = url else { return nil }
        if let cached = ImageCache.shared.image(for: url) {
            return cached
        }

        loadTask = Task { [weak self] in
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard !Task.isCancelled else { return nil }
                let image = UIImage(data: data)
                if let image {
                    ImageCache.shared.insertImage(image, for: url)
                }
                return image
            } catch {
                self?.handleImageLoadingError(error)
                return nil
            }
        }

        return await loadTask?.value
    }

    func cancel() {
        loadTask?.cancel()
    }

    private func handleImageLoadingError(_ error: Error) {
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
