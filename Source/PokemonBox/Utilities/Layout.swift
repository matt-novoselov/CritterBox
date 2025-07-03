//
//  Layout.swift
//  PokemonBox
//
//  Created by Matt Novoselov on 05/07/25.
//

import UIKit

/// Common layout constants used across views.
enum Layout {
    /// Horizontal insets for table and collection views.
    static let horizontalInset: CGFloat = 16

    /// Leading inset for cell artwork image.
    static let cellImageLeading: CGFloat = 8
    /// Size (width/height) for cell artwork image.
    static let cellImageSize: CGFloat = 72

    /// Vertical spacing between cell elements (name/types/flavor).
    static let cellElementSpacing: CGFloat = 4
    /// Bottom inset for cell content.
    static let cellInset: CGFloat = 20
}
