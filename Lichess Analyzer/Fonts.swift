//
//  Fonts.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 26/10/2020.
//

import UIKit

enum Style {
    case hairline, thin, light, medium, bold

    var name: String {
        switch self {
        case .hairline: return "Lato-Hairline"
        case .thin: return "Lato-Thin"
        case .light: return "Lato-Light"
        case .medium: return "Lato-Medium"
        case .bold: return "Lato-Bold"
        }
    }
}

class Font {

    static func with(_ style: Style, _ size: Int) -> UIFont {
        return UIFont(name: style.name, size: CGFloat(size))!
    }

}
