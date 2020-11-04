//
//  FilterButton.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 30/10/2020.
//

import UIKit


class FilterButton: UIButton {

    @IBInspectable var sorting: String = "" {
        didSet {
            totalText = title(for: .normal) ?? ""
        }
    }
    var isCurrent = false

    var totalText = ""


    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 10
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layer.borderColor = UIColor(hex: "42729D").cgColor
        backgroundColor = .clear
        setTitleColor(UIColor(hex: "42729D"), for: .normal)
        tintColor = UIColor(hex: "42729D")
    }

    func didSelect() {
        if let filterStack = superview as? FilterStackView {
            filterStack.update(sorting)
        }
    }

    func selected() {
        layer.borderWidth = 2
        isCurrent = true
    }

    func unselected() {
        layer.borderWidth = 0
        isCurrent = false
    }
}

class FilterStackView: UIStackView {


    func update(_ selectedSorting: String) {
        for case let button as FilterButton in subviews {
            button.sorting == selectedSorting ? button.selected() : button.unselected()
        }
    }

    func move() {
        for case let button as FilterButton in subviews {
            if button.isCurrent {
                removeArrangedSubview(button)
                insertArrangedSubview(button, at: 0)
                return
            }
        }
    }
}
