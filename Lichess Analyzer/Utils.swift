//
//  Utils.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 21/10/2020.
//

import UIKit


extension Int {

    var double: Double {
        Double(self)
    }

    func percentage(of: Int) -> Double {
        guard self > 0 else { return 0 }
        return ((self.double/of.double)*100).rounded(toPlaces: 1)
    }

    func percentageInt(of: Int) -> Int {
        return Int(((self.double/of.double)*100))
    }

    func secondsToMinutesSecondsString() -> String {
        let (m, s) = secondsToMinutesSeconds()
        let secondString = s == 1 ? "1 Second" : "\(s) Seconds"
        return self < 60 ?
            secondString :
            "\(m) Min: \(secondString)"
    }

    func secondsToMinutesSeconds() -> (Int, Int) {
        return ((self % 3600) / 60, (self % 3600) % 60)
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
    var boldFont:UIFont { return Font.with(.medium, Int(fontSize)) }
    var normalFont:UIFont { return Font.with(.light, Int(fontSize)) }

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
        case let x where x < 50: return UIColor(hex: "D6B218")
        case let x where x < 60: return UIColor(hex: "BAB231")
        case let x where x < 70: return UIColor(hex: "7F8935")
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

    func setSelfConstraint(constraint: NSLayoutConstraint.Attribute, constant: CGFloat) {
        if translatesAutoresizingMaskIntoConstraints == true {
            translatesAutoresizingMaskIntoConstraints = false
        }
        addConstraint(NSLayoutConstraint(item: self,
                                         attribute: .height,
                                         relatedBy: .equal,
                                         toItem: nil,
                                         attribute: .height,
                                         multiplier: 1,
                                         constant: constant))
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

extension UILabel {

    func changeText(_ string: String) {
        UIView.transition(with: self,
                          duration: 0.25,
                          options: .transitionCrossDissolve,
                          animations: { [weak self] in
                            self?.text = string
                          }, completion: nil)
    }
}

extension String {

    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo]).replacingOccurrences(of: "\"", with: "")
            }
        }
    }
}

extension BinaryInteger {
    var degreesToRadians: CGFloat { CGFloat(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}


extension Date {

    var day: Int {
        return Calendar.current.component(.day, from: self)
    }

    var month: Int {
        return Calendar.current.component(.month, from: self)
    }

    var year: Int {
        return Calendar.current.component(.year, from: self)
    }

    var millisecondsSince1970: Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    func toString(_ format: String = "dd-MM-yyyy") -> String? {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = format
        return dateFormat.string(from: self)
    }
}

extension String {

    func toDate(_ format: String = "dd-MM-yyyy") -> Date? {
        let dateFormat = DateFormatter()
        dateFormat.timeZone = TimeZone.init(identifier: "UTC")
        dateFormat.dateFormat = format
        return dateFormat.date(from: self)
    }
}


extension Dictionary {

    func sortedKeys(isOrderedBefore:(Key,Key) -> Bool) -> [Key] {
        return Array(self.keys).sorted(by: isOrderedBefore)
    }

    func sortedKeysByValue(isOrderedBefore:(Value, Value) -> Bool) -> [Key] {
        return sortedKeys {
            isOrderedBefore(self[$0]!, self[$1]!)
        }
    }

    // Faster because of no lookups, may take more memory because of duplicating contents
    func keysSortedByValue(isOrderedBefore:(Value, Value) -> Bool) -> [Key] {
        return Array(self)
            .sorted { (k, v) -> Bool in
                let (_, lv) = k
                let (_, rv) = v
                return isOrderedBefore(lv, rv)
            }
            .map {
                let (k, _) = $0
                return k
            }
    }
}
