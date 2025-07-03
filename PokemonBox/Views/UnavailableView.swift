//
//  UnavailableView.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 02/07/25.
//

import UIKit

/// A view used when search returns no results.
/// Displays a slightly transparent silhouette image with a title and message.
final class UnavailableView: UIView {

    // MARK: - UI Components
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .silhouettePlaceholder))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.3
        imageView.isAccessibilityElement = false
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bricolageGrotesque(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        label.isAccessibilityElement = true
        label.accessibilityTraits = .header
        return label
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isAccessibilityElement = true
        label.accessibilityTraits = .staticText
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel, messageLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        return stack
    }()

    // MARK: - Initializers
    convenience init(title: String, message: String) {
        self.init(frame: .zero)
        configure(title: title, message: message)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Public Methods
    /// Updates the title and message displayed by the view.
    func configure(title: String, message: String) {
        titleLabel.text = title
        messageLabel.text = message
    }

    // MARK: - Private Setup
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 80),
            imageView.widthAnchor.constraint(lessThanOrEqualToConstant: 80),

            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16)
        ])
    }
}
