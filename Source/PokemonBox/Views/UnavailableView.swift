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
        $0.image = UIImage(resource: .silhouettePlaceholder)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.alpha = 0.3
        $0.isAccessibilityElement = false
        return $0
    }(UIImageView())

    private lazy var titleLabel: UILabel = {
        $0.font = UIFont.bricolageGrotesque(ofSize: 22, weight: .bold)
        $0.textAlignment = .center
        $0.isAccessibilityElement = true
        $0.accessibilityTraits = .header
        return $0
    }(UILabel())

    private lazy var messageLabel: UILabel = {
        $0.font = .preferredFont(forTextStyle: .body)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.isAccessibilityElement = true
        $0.accessibilityTraits = .staticText
        return $0
    }(UILabel())

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
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: Layout.horizontalInset),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Layout.horizontalInset)
        ])
    }
}
