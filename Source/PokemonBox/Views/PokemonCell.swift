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

    private let artworkView = ArtworkImageView()
    private let nameLabel = UILabel()
    private let typesStackView = UIStackView()
    private let flavorLabel = UILabel()

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
        artworkView.prepareForReuse()
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

        artworkView.loadImage(from: viewModel.artworkURL)
    }
}

// MARK: - View Lifecycle Helpers
private extension PokemonCell {
    func setupViews() {
        selectionStyle = .none

        [artworkView, nameLabel, typesStackView, flavorLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            artworkView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.cellImageLeading),
            artworkView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.cellInset),
            artworkView.widthAnchor.constraint(equalToConstant: Layout.cellImageSize),
            artworkView.heightAnchor.constraint(equalToConstant: Layout.cellImageSize),

            nameLabel.leadingAnchor.constraint(equalTo: artworkView.trailingAnchor, constant: Layout.horizontalInset),
            nameLabel.topAnchor.constraint(equalTo: artworkView.topAnchor),
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

}
