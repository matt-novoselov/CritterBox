//
//  ViewController.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 01/07/25.
//

import UIKit

extension UIFont {
    /// Returns the Bricolage Grotesque font bundled with the app.
    /// - Parameters:
    ///   - size: Font size in points.
    ///   - weight: Desired font weight. Defaults to `.regular`.
    /// - Returns: Custom font if available, otherwise the system font.
    static func bricolageGrotesque(ofSize size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let descriptor = UIFontDescriptor(fontAttributes: [
            .family: AppConstants.bricolageGrotesqueFontName,
            .traits: [UIFontDescriptor.TraitKey.weight: weight]
        ])
        if let font = UIFont(descriptor: descriptor, size: size) as UIFont? {
            return font
        }
        return .systemFont(ofSize: size, weight: weight)
    }
}
