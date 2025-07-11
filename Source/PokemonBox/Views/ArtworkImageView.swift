import UIKit

/// A view that asynchronously loads and displays a Pokémon artwork image.
final class ArtworkImageView: UIView {
    private let imageView = UIImageView()
    private let spinner = UIActivityIndicatorView(style: .large)
    private let viewModel = ArtworkImageViewModel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
    }

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
}

private extension ArtworkImageView {
    func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        addSubview(spinner)
    }

    func setupConstraints() {
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
