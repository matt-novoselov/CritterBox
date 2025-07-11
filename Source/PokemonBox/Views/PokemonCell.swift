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
    
    // Stack views for layout
    private let horizontalStackView = UIStackView()
    private let verticalStackView = UIStackView()

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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutMargins = UIEdgeInsets(top: 0, left: Layout.horizontalInset, bottom: 0, right:  Layout.horizontalInset)
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

        // Configure vertical stack view for vertical layout of labels
        verticalStackView.axis = .vertical
        verticalStackView.spacing = Layout.cellElementSpacing
        verticalStackView.alignment = .leading
        verticalStackView.addArrangedSubview(nameLabel)
        verticalStackView.addArrangedSubview(typesStackView)
        verticalStackView.addArrangedSubview(flavorLabel)

        // Configure horizontal stack view for horizontal layout of image and vertical stack
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = Layout.horizontalInset
        horizontalStackView.alignment = .top
        horizontalStackView.addArrangedSubview(artworkView)
        horizontalStackView.addArrangedSubview(verticalStackView)
        
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(horizontalStackView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            // Keep image view at a fixed size
            artworkView.widthAnchor.constraint(equalToConstant: Layout.cellImageSize),
            artworkView.heightAnchor.constraint(equalToConstant: Layout.cellImageSize),
            
            // Pin horizontal stack view to the content view's margins with vertical insets
            horizontalStackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            horizontalStackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            horizontalStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.cellInset),
            horizontalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.cellInset)
        ])
    }

}
