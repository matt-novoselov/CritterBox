//
//  ViewController.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 01/07/25.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let label = UILabel()
        label.text = "Hello World"
        label.textAlignment = .center
        label.font = .bricolageGrotesque(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task {
            do {
                let service = PokemonService()
                let pokemons = try await service.fetchAllPokemon(limit: 20)
                dump(pokemons)
            } catch {
                print("Failed to fetch pokemons: \(error)")
            }
        }
    }
}
