//
//  AnimatingImage.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 10/11/2020.
//

import UIKit

class AnimatingImage: UIImageView {

    @IBInspectable var delay: Int = 0
    var isOn = true

    override func awakeFromNib() {
        super.awakeFromNib()
        self.start()
    }

    deinit {
        self.layer.removeAllAnimations()
    }

    func rotateRight(_ delay: Double) {
        UIView.animate(withDuration: 4.5, delay: delay, options: [.curveEaseInOut]) {
            self.transform = CGAffineTransform(rotationAngle: 0.1)
        } completion: { [weak self] _ in
            self?.rotateLeft(0)
        }
    }

    func rotateLeft(_ delay: Double) {
        UIView.animate(withDuration: 4.5, delay: delay, options: [.curveEaseInOut]) {
            self.transform = CGAffineTransform(rotationAngle: -0.1)
        } completion: { [weak self] _ in
            self?.rotateRight(0)
        }
    }

    func start() {
        if arc4random_uniform(2) == 1 {
            rotateRight(Double(delay))
        } else {
            rotateLeft(Double(delay))
        }
    }
}
