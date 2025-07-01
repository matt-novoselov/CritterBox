import UIKit

class PokemonCell: UITableViewCell {
    static let reuseIdentifier = "PokemonCell"

    private let artworkImageView = UIImageView()
    private let nameLabel = UILabel()
    private let typesStackView = UIStackView()
    private let flavorLabel = UILabel()

    private var task: Task<Void, Never>?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        artworkImageView.translatesAutoresizingMaskIntoConstraints = false
        artworkImageView.contentMode = .scaleAspectFit

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .preferredFont(forTextStyle: .headline)

        typesStackView.translatesAutoresizingMaskIntoConstraints = false
        typesStackView.axis = .horizontal
        typesStackView.spacing = 4

        flavorLabel.translatesAutoresizingMaskIntoConstraints = false
        flavorLabel.font = .preferredFont(forTextStyle: .body)
        flavorLabel.numberOfLines = 0

        contentView.addSubview(artworkImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(typesStackView)
        contentView.addSubview(flavorLabel)

        NSLayoutConstraint.activate([
            artworkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            artworkImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            artworkImageView.widthAnchor.constraint(equalToConstant: 96),
            artworkImageView.heightAnchor.constraint(equalToConstant: 96),

            nameLabel.leadingAnchor.constraint(equalTo: artworkImageView.trailingAnchor, constant: 8),
            nameLabel.topAnchor.constraint(equalTo: artworkImageView.topAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            typesStackView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            typesStackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            typesStackView.trailingAnchor.constraint(lessThanOrEqualTo: nameLabel.trailingAnchor),

            flavorLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            flavorLabel.topAnchor.constraint(equalTo: typesStackView.bottomAnchor, constant: 4),
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
        typesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for type in pokemon.types {
            let label = PaddingLabel()
            label.text = type.capitalized
            label.font = .preferredFont(forTextStyle: .caption1)
            label.backgroundColor = .systemGray5
            label.layer.cornerRadius = 4
            label.layer.masksToBounds = true
            typesStackView.addArrangedSubview(label)
        }
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

