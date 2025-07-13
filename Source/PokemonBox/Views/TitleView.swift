//
//  TitleView.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 12/07/25.
//

import UIKit

/// A custom view for the navigation bar title, displaying "Pokemon" and "Box" with different font weights.
final class TitleView: UIView {

    // MARK: - UI Components
    private lazy var pokemonLabel: UILabel = {
        $0.text = "Pokemon"
        $0.font = UIFont.bricolageGrotesque(ofSize: 26, weight: .regular)
        $0.isAccessibilityElement = false
        return $0
    }(UILabel())

    private lazy var boxLabel: UILabel = {
        $0.text = "Box"
        $0.font = UIFont.bricolageGrotesque(ofSize: 26, weight: .bold)
        $0.isAccessibilityElement = false
        return $0
    }(UILabel())

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [pokemonLabel, boxLabel])
        stack.isAccessibilityElement = true
        stack.accessibilityTraits = .header
        stack.accessibilityLabel = "PokemonBox"
        return stack
    }()

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Private Setup
    private func setupView() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
