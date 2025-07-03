//
//  PokemonCell.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 01/07/25.
//

import UIKit

// A table view cell for displaying a single Pokémon with its details.
class PokemonCell: UITableViewCell {
    static let reuseIdentifier = "PokemonCell"

    private let artworkImageView = UIImageView()
    private let spinner = UIActivityIndicatorView(style: .large)
    private let nameLabel = UILabel()
    private let typesStackView = UIStackView()
    private let flavorLabel = UILabel()

    private var imageLoadTask: Task<Void, Never>?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        artworkImageView.image = nil
        spinner.startAnimating()
    }

    /// Configures the cell with data from a view model.
    /// - Parameter viewModel: The view model containing the Pokémon's information.
    func configure(with viewModel: PokemonCellViewModel) {
        nameLabel.text = viewModel.name
        let headline = UIFont.preferredFont(forTextStyle: .headline)
        nameLabel.font = UIFont.bricolageGrotesque(ofSize: headline.pointSize, weight: .bold)
        flavorLabel.text = viewModel.flavorText
        flavorLabel.font = .preferredFont(forTextStyle: .body)
        flavorLabel.textColor = .secondaryLabel
        flavorLabel.numberOfLines = 0
        isAccessibilityElement = true
        accessibilityLabel = viewModel.accessibilityLabel

        typesStackView.spacing = Layout.cellElementSpacing
        typesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for type in viewModel.types {
            let label = PaddingLabel()
            label.text = type
            let base = UIFont.preferredFont(forTextStyle: .caption1)
            label.font = .boldSystemFont(ofSize: base.pointSize + 2)
            label.textColor = .secondaryLabel
            label.backgroundColor = .systemGray5
            label.layer.cornerRadius = 4
            label.layer.masksToBounds = true
            typesStackView.addArrangedSubview(label)
        }

        loadArtwork(from: viewModel.artworkURL)
    }
}

// MARK: - View Lifecycle Helpers
private extension PokemonCell {
    func setupViews() {
        selectionStyle = .none
        artworkImageView.contentMode = .scaleAspectFit

        [artworkImageView, nameLabel, typesStackView, flavorLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        spinner.translatesAutoresizingMaskIntoConstraints = false
        artworkImageView.addSubview(spinner)
        spinner.startAnimating()
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            artworkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.cellImageLeading),
            artworkImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.cellInset),
            artworkImageView.widthAnchor.constraint(equalToConstant: Layout.cellImageSize),
            artworkImageView.heightAnchor.constraint(equalToConstant: Layout.cellImageSize),
            spinner.centerXAnchor.constraint(equalTo: artworkImageView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: artworkImageView.centerYAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: artworkImageView.trailingAnchor, constant: Layout.horizontalInset),
            nameLabel.topAnchor.constraint(equalTo: artworkImageView.topAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.horizontalInset),

            typesStackView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            typesStackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Layout.cellElementSpacing),
            typesStackView.trailingAnchor.constraint(lessThanOrEqualTo: nameLabel.trailingAnchor),

            flavorLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            flavorLabel.topAnchor.constraint(equalTo: typesStackView.bottomAnchor, constant: Layout.cellElementSpacing),
            flavorLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            flavorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.cellInset)
        ])
    }

    /// Asynchronously loads the Pokémon's artwork from a URL, with caching.
    /// - Parameter url: The URL of the artwork image.
    func loadArtwork(from url: URL?) {
        imageLoadTask?.cancel()
        artworkImageView.image = nil
        guard let url = url else {
            spinner.stopAnimating()
            return
        }
        spinner.startAnimating()
        if let cached = ImageCache.shared.image(for: url) {
            artworkImageView.image = cached
            spinner.stopAnimating()
        } else {
            imageLoadTask = Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    guard !Task.isCancelled, let image = UIImage(data: data) else { return }
                    ImageCache.shared.insertImage(image, for: url)
                    DispatchQueue.main.async {
                        self.artworkImageView.image = image
                    }
                } catch {
                    print("Artwork loading error: \(error)")
                }
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                }
            }
        }
    }
}
