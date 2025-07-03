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
    private let imageView = UIImageView(image: UIImage(resource: .silhouettePlaceholder))
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.3
        imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 80).isActive = true
        imageView.widthAnchor.constraint(lessThanOrEqualToConstant: 80).isActive = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.bricolageGrotesque(ofSize: 22, weight: .bold)
        titleLabel.textAlignment = .center

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = .preferredFont(forTextStyle: .body)
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel, messageLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        imageView.isAccessibilityElement = false
        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityTraits = .header
        messageLabel.isAccessibilityElement = true
        messageLabel.accessibilityTraits = .staticText

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16)
        ])
    }

    /// Updates the title and message displayed by the view.
    func configure(title: String, message: String) {
        titleLabel.text = title
        messageLabel.text = message
    }
}
