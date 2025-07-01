import UIKit

class PokemonCell: UITableViewCell {
    static let reuseIdentifier = "PokemonCell"

    private let artworkImageView = UIImageView()
    private let nameLabel = UILabel()
    private let typesLabel = UILabel()
    private let flavorLabel = UILabel()

    private var task: Task<Void, Never>?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        artworkImageView.translatesAutoresizingMaskIntoConstraints = false
        artworkImageView.contentMode = .scaleAspectFit

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .preferredFont(forTextStyle: .headline)

        typesLabel.translatesAutoresizingMaskIntoConstraints = false
        typesLabel.font = .preferredFont(forTextStyle: .subheadline)
        typesLabel.textColor = .secondaryLabel

        flavorLabel.translatesAutoresizingMaskIntoConstraints = false
        flavorLabel.font = .preferredFont(forTextStyle: .body)
        flavorLabel.numberOfLines = 0

        contentView.addSubview(artworkImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(typesLabel)
        contentView.addSubview(flavorLabel)

        NSLayoutConstraint.activate([
            artworkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            artworkImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            artworkImageView.widthAnchor.constraint(equalToConstant: 64),
            artworkImageView.heightAnchor.constraint(equalToConstant: 64),

            nameLabel.leadingAnchor.constraint(equalTo: artworkImageView.trailingAnchor, constant: 8),
            nameLabel.topAnchor.constraint(equalTo: artworkImageView.topAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            typesLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            typesLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            typesLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            flavorLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            flavorLabel.topAnchor.constraint(equalTo: typesLabel.bottomAnchor, constant: 4),
            flavorLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            flavorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
        artworkImageView.image = nil
    }

    func configure(with pokemon: Pokemon) {
        nameLabel.text = pokemon.name.capitalized
        typesLabel.text = pokemon.types.joined(separator: ", ")
        flavorLabel.text = pokemon.flavorText
        if let url = pokemon.artworkURL {
            task = Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if !Task.isCancelled {
                        artworkImageView.image = UIImage(data: data)
                    }
                } catch {
                    // ignore loading errors
                }
            }
        }
    }
}

