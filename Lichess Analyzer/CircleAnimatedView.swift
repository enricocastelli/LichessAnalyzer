//
//  CircleAnimatedView.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 26/10/2020.
//

import UIKit

class CircleAnimatedView: UIView {
  
    var circleLayer = CAShapeLayer()

    let wins: Double, loss: Double, draw: Double
    var winCircle: SingleCircle!
    var lossCircle: SingleCircle!
    var drawCircle: SingleCircle!


    init(wins: Double, loss: Double, draw: Double) {
        self.wins = wins
        self.loss = loss
        self.draw = draw
        super.init(frame: .zero)
        addCircleViews()
    }

    private func addCircleViews() {
        winCircle = SingleCircle(from: 0, to: wins, color: UIColor(hex: "56AB59"))
        drawCircle = SingleCircle(from: wins, to: wins + draw, color: UIColor(hex: "F3C419"))
        lossCircle = SingleCircle(from: wins + draw, to: 1, color: UIColor(hex: "DA2418"))
        addContentView(lossCircle)
        addContentView(drawCircle)
        addContentView(winCircle)
    }


    func animate(_ delay: Double) {
        let circles = [winCircle, drawCircle, lossCircle]
        var delay = delay
        for ind in 0...2 {
            circles[ind]?.animate(delay)
            delay += 0.2
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SingleCircle: UIView {

    let from: Double
    let to: Double
    let color: UIColor

    var circleLayer = CAShapeLayer()

    init(from: Double, to: Double, color: UIColor) {
        self.from = from
        self.to = to
        self.color = color
        super.init(frame: .zero)
        addCircleLayer()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let bound = CGRect(x: 0, y: 0, width: frame.width, height: frame.width)
        let circlePath = UIBezierPath(ovalIn: bound)
        circleLayer.path = circlePath.cgPath
    }

    private func addCircleLayer() {
        let bound = CGRect(x: 0, y: 0, width: frame.width, height: frame.width)
        let circlePath = UIBezierPath(ovalIn: bound)
        circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        circleLayer.lineCap = .butt
        circleLayer.strokeStart = 0
        circleLayer.strokeEnd = 0
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = color.cgColor
        circleLayer.lineWidth = 20
        layer.addSublayer(circleLayer)
    }

    func animate(_ duration: Double) {
        let _ = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { (_) in
            self.circleLayer.strokeStart = CGFloat(self.from)
            self.circleLayer.strokeEnd = CGFloat(self.to)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


