//
//  Utils.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 21/10/2020.
//

import UIKit

class UserData {

    static let shared = UserData()

    var name: String = ""
    var search: (color: Color, gameType: GameType) = (Color.white, GameType.blitz)

    var openings = [OpeningObject]()

    func updateOpenings() {
        if let path = Bundle.main.path(forResource: "Openings", ofType: "json")
        {
            if let jsonData = NSData(contentsOfFile: path) {
                do {
                    self.openings = try JSONDecoder().decode([OpeningObject].self, from: Data(jsonData))
                } catch(let error) {
                    print(error, "nope")
                }
            }
        }
    }
}

extension Int {

    var double: Double {
        Double(self)
    }

    func percentage(of: Int) -> Double {
        guard self > 0 else { return 0 }
        return ((self.double/of.double)*100).rounded(toPlaces: 2)
    }

    func percentageInt(of: Int) -> Int {
        return Int(((self.double/of.double)*100))
    }
}

extension CGFloat {
    var nonNegative: CGFloat? {
        guard isFinite && !isNaN && self >= 0 else { return nil }
        return self
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension NSMutableAttributedString {
    var fontSize:CGFloat { return 14 }
    var boldFont:UIFont { return UIFont(name: "AvenirNext-Bold", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize) }
    var normalFont:UIFont { return UIFont(name: "AvenirNext-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)}

    func bold(_ value:String) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font : boldFont
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }

    func normal(_ value:String) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font : normalFont,
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }

    func colorText(_ value:String, _ color: UIColor) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor : color
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
}

extension UIColor {

    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }

    static func percentageColor(_ value: Double) -> UIColor {
        switch value {
        case let x where x < 20: return UIColor(hex: "DA2418")
        case let x where x < 30: return UIColor(hex: "DA5C18")
        case let x where x < 40: return UIColor(hex: "DA8B18")
        case let x where x < 50: return UIColor(hex: "646464")
        case let x where x < 60: return UIColor(hex: "6C7B98")
        case let x where x < 70: return UIColor(hex: "637F5F")
        case let x where x < 80: return UIColor(hex: "568D58")
        case let x where x < 90: return UIColor(hex: "56AB59")
        default: return UIColor(hex: "15900A")
        }
    }
}

extension UIView {

    func setConstraint(constraint: NSLayoutConstraint.Attribute, constant: CGFloat) {
        guard let superview = superview else { return }
        if translatesAutoresizingMaskIntoConstraints == true {
            translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.init(item: self,
                                attribute: constraint,
                                relatedBy: .equal,
                                toItem: superview,
                                attribute: constraint,
                                multiplier: 1,
                                constant: constant).isActive = true
    }

    func addContentView(_ contentView: UIView, _ atIndex: Int? = nil) {
        let containerView = self
        contentView.translatesAutoresizingMaskIntoConstraints = false
        if let atIndex = atIndex {
            containerView.insertSubview(contentView, at: atIndex)
        } else {
            containerView.addSubview(contentView)
        }
        NSLayoutConstraint.init(item: contentView,
                                attribute: .top,
                                relatedBy: .equal,
                                toItem: containerView,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0).isActive = true
        NSLayoutConstraint.init(item: contentView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: containerView,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0).isActive = true
        NSLayoutConstraint.init(item: contentView,
                                attribute: .right,
                                relatedBy: .equal,
                                toItem: containerView,
                                attribute: .right,
                                multiplier: 1,
                                constant: 0).isActive = true
        NSLayoutConstraint.init(item: contentView,
                                attribute: .left,
                                relatedBy: .equal,
                                toItem: containerView,
                                attribute: .left,
                                multiplier: 1,
                                constant: 0).isActive = true
    }
}

