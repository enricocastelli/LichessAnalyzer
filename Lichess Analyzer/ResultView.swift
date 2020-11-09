//
//  ResultView.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 26/10/2020.
//

import UIKit

class ResultView: NibView {

    @IBOutlet weak var noResultLabel: UILabel!
    @IBOutlet weak var drawLabel: UILabel!
    @IBOutlet weak var winLabel: UILabel!
    @IBOutlet weak var lossLabel: UILabel!
    @IBOutlet weak var winPercentageLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var columnStackView: UIView!

    var circleView: CircleAnimatedView?

    var wins: Int?
    var loss: Int?
    var draw: Int?
    var totalGames: Int {
        return (wins ?? 0) + (loss ?? 0) + (draw ?? 0)
    }

    func update(wins: Int, loss: Int, draw: Int) {
        self.wins = wins
        self.loss = loss
        self.draw = draw
        circleView?.removeFromSuperview()
        setView()
    }

    func hideColumn() {
        columnStackView.isHidden = true
    }

    override func nibSetup() {
        super.nibSetup()
        setView()
    }

    private func setView() {
        guard let wins = wins, let loss = loss, let draw = draw, totalGames > 0 else {
            setNoResult()
            return }
        setForResult()
        circleView = CircleAnimatedView(wins: wins.percentage(of: totalGames)/100, loss: loss.percentage(of: totalGames)/100, draw: draw.percentage(of: totalGames)/100)
        self.containerView.addContentView(circleView!)
        preanimate()
        circleView?.animate(0.5)
        UIView.animateKeyframes(withDuration: 0.5, delay: 1, options: []) {
            self.animateLabels()
        }
        drawLabel.text = draw.description + " DRAWS"
        winLabel.text = wins.description + " WINS"
        lossLabel.text = loss.description + " LOSSES"
        winPercentageLabel.text = wins.percentage(of: totalGames).description + "% WINS"
    }

    private func setNoResult() {
        noResultLabel.isHidden = false
        drawLabel.isHidden = true
        winLabel.isHidden = true
        lossLabel.isHidden = true
        winPercentageLabel.isHidden = true
        if columnStackView.isHidden {
            // suggestionVC
            noResultLabel.text = "YOU NEVER PLAYED AGAINST THIS PLAYER"
        }
    }

    private func setForResult() {
        noResultLabel.isHidden = true
        drawLabel.isHidden = false
        winLabel.isHidden = false
        lossLabel.isHidden = false
        winPercentageLabel.isHidden = false
    }

    private func preanimate() {
        drawLabel.alpha = 0
        winLabel.alpha = 0
        lossLabel.alpha = 0
        winPercentageLabel.alpha = 0
        winLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        lossLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        winPercentageLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        drawLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
    }

    private func animateLabels() {
        drawLabel.alpha = 1
        winLabel.alpha = 1
        lossLabel.alpha = 1
        winPercentageLabel.alpha = 1
        drawLabel.transform = CGAffineTransform.identity
        winLabel.transform = CGAffineTransform.identity
        lossLabel.transform = CGAffineTransform.identity
        winPercentageLabel.transform = CGAffineTransform.identity
    }

}
