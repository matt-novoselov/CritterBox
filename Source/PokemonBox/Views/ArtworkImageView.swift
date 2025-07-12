import UIKit

/// A view that asynchronously loads and displays a Pokémon artwork image.
final class ArtworkImageView: UIView {

    // MARK: - UI Components
    private lazy var imageView: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        return $0
    }(UIImageView())

    private lazy var spinner: UIActivityIndicatorView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIActivityIndicatorView(style: .large))

    private let viewModel = ArtworkImageViewModel()

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Public Methods
    /// Begins loading an image from the given URL.
    /// - Parameter url: The image URL.
    func loadImage(from url: URL?) {
        spinner.startAnimating()
        viewModel.load(url: url) { [weak self] image in
            DispatchQueue.main.async {
                self?.imageView.image = image
                self?.spinner.stopAnimating()
            }
        }
    }

    /// Cancels any ongoing load and resets the view.
    func prepareForReuse() {
        viewModel.cancel()
        imageView.image = nil
        spinner.startAnimating()
    }
    
    // MARK: - Private Setup
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        addSubview(spinner)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
