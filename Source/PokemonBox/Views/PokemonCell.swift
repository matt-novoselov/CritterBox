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

    // MARK: - UI Components
    private lazy var artworkView = ArtworkImageView()

    private lazy var nameLabel = UILabel()

    private lazy var typesStackView: UIStackView = {
        $0.spacing = Layout.cellElementSpacing
        return $0
    }(UIStackView())

    private lazy var flavorLabel: UILabel = {
        $0.font = .preferredFont(forTextStyle: .body)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 0
        return $0
    }(UILabel())

    private lazy var verticalStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, typesStackView, flavorLabel])
        stack.axis = .vertical
        stack.spacing = Layout.cellElementSpacing
        stack.alignment = .leading
        return stack
    }()

    private lazy var horizontalStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [artworkView, verticalStackView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = Layout.horizontalInset
        stack.alignment = .center
        return stack
    }()

    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        artworkView.prepareForReuse()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutMargins = UIEdgeInsets(top: 0, left: Layout.horizontalInset, bottom: 0, right: Layout.horizontalInset)
    }

    // MARK: - Public Methods
    /// Configures the cell with data from a view model.
    /// - Parameter viewModel: The view model containing the Pokémon's information.
    func configure(with viewModel: PokemonCellViewModel) {
        nameLabel.text = viewModel.name
        let headline = UIFont.preferredFont(forTextStyle: .headline)
        nameLabel.font = UIFont.bricolageGrotesque(ofSize: headline.pointSize, weight: .bold)

        flavorLabel.text = viewModel.flavorText

        isAccessibilityElement = true
        accessibilityLabel = viewModel.accessibilityLabel

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
