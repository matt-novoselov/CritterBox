import UIKit

class PokemonCell: UITableViewCell {
    static let reuseIdentifier = "PokemonCell"

    private let artworkImageView = UIImageView()
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let nameLabel = UILabel()
    private let typesStackView = UIStackView()
    private let flavorLabel = UILabel()

    private var task: Task<Void, Never>?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        artworkImageView.translatesAutoresizingMaskIntoConstraints = false
        artworkImageView.contentMode = .scaleAspectFit
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        let headline = UIFont.preferredFont(forTextStyle: .headline)
        nameLabel.font = .boldSystemFont(ofSize: headline.pointSize)

        typesStackView.translatesAutoresizingMaskIntoConstraints = false
        typesStackView.axis = .horizontal
        typesStackView.spacing = 4

        flavorLabel.translatesAutoresizingMaskIntoConstraints = false
        flavorLabel.font = .preferredFont(forTextStyle: .body)
        flavorLabel.textColor = .secondaryLabel
        flavorLabel.numberOfLines = 0

        selectionStyle = .none
        contentView.addSubview(artworkImageView)
        artworkImageView.addSubview(spinner)
        spinner.startAnimating()
        contentView.addSubview(nameLabel)
        contentView.addSubview(typesStackView)
        contentView.addSubview(flavorLabel)

        NSLayoutConstraint.activate([
            artworkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            artworkImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            artworkImageView.widthAnchor.constraint(equalToConstant: 72),
            artworkImageView.heightAnchor.constraint(equalToConstant: 72),
            spinner.centerXAnchor.constraint(equalTo: artworkImageView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: artworkImageView.centerYAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: artworkImageView.trailingAnchor, constant: 16),
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
        spinner.startAnimating()
    }

    func configure(with pokemon: Pokemon) {
        nameLabel.text = pokemon.name.capitalized
        typesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for type in pokemon.types {
            let label = PaddingLabel()
            label.text = type.capitalized
            let base = UIFont.preferredFont(forTextStyle: .caption1)
            label.font = .boldSystemFont(ofSize: base.pointSize + 2)
            label.textColor = .tertiaryLabel
            label.backgroundColor = .systemGray5
            label.layer.cornerRadius = 4
            label.layer.masksToBounds = true
            typesStackView.addArrangedSubview(label)
        }
        flavorLabel.text = pokemon.flavorText
        if let url = pokemon.artworkURL {
            spinner.startAnimating()
            task = Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if !Task.isCancelled {
                        artworkImageView.image = UIImage(data: data)
                        spinner.stopAnimating()
                    }
                } catch {
                    // ignore loading errors
                    spinner.stopAnimating()
                }
            }
        } else {
            spinner.stopAnimating()
        }
    }
}

