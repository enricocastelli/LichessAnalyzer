//
//  SuggestionVC.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 09/11/2020.
//

import UIKit
import FirebaseAnalytics

class SuggestionVC: UIViewController, ServiceProvider {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    @IBOutlet weak var resultView: ResultView!
    @IBOutlet weak var compressConstraint: NSLayoutConstraint!
    @IBOutlet weak var expandedConstraint: NSLayoutConstraint!
    @IBOutlet weak var whiteButton: UIButton!
    @IBOutlet weak var blackButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mostLabel: OpeningLabel!
    @IBOutlet weak var weakLabel: OpeningLabel!
    @IBOutlet weak var strongLabel: OpeningLabel!
    @IBOutlet weak var mostView: UIView!
    @IBOutlet weak var weakView: UIView!
    @IBOutlet weak var strongView: UIView!
    @IBOutlet var images: [AnimatingImage]!

    var color = Color.white

    override func viewDidLoad() {
        super.viewDidLoad()
        Analytics.logEvent("Suggestion", parameters: ["name": U.shared.searchName])
        showLoadingAnimation()
        nameLabel.text = U.shared.searchName
        historyLabel.text = "\(U.shared.account?.username ?? "") against \(U.shared.searchName):"
        titleLabel.text = "\(U.shared.searchName) plays mostly"
        getData()
        resultView.hideColumn()
        whiteTapped()
        mostView.layer.borderColor = mostView.backgroundColor?.withAlphaComponent(0.5).cgColor
        weakView.layer.borderColor = weakView.backgroundColor?.withAlphaComponent(0.5).cgColor
        strongView.layer.borderColor = strongView.backgroundColor?.withAlphaComponent(0.5).cgColor
    }

    func getData() {
        getVCGames { (games) in
            self.hideLoadingAnimation()
            guard let games = games else { return }
            games.isEmpty ? self.hideResultView() : self.showResultView()
            self.resultView.update(wins: games.lost(), loss: games.wins(), draw: games.draw())
        } failure: { (error) in
            self.hideLoadingAnimation()
        }
    }

    private func reload() {
        let most = U.shared.games.findMost(sort: .mostPlayed, using: color)
        let strong = U.shared.games.findMost(sort: .strongest, using: color)
        let weak = U.shared.games.findMost(sort: .weakest, using: color)
        mostView.isHidden = most == nil
        weakView.isHidden = weak == nil
        strongView.isHidden = strong == nil
        if strong == weak {
            strongView.isHidden = true
        }
        strongLabel.opening = strong
        weakLabel.opening = weak
        mostLabel.opening = most
    }

    private func animateTransition() {
        let option: UIView.AnimationOptions = color == .white ? .transitionFlipFromRight : .transitionFlipFromLeft
        UIView.transition(with: mostView, duration: 0.25, options: option, animations: nil, completion: nil)
        UIView.transition(with: weakView, duration: 0.3, options: option, animations: nil, completion: nil)
        UIView.transition(with: strongView, duration: 0.35, options: option, animations: nil, completion: nil)
        let pieceImages = color == .white ? [UIImage(named: "knightB"), UIImage(named: "queenB"), UIImage(named: "pawnB")] : [UIImage(named: "knightW"), UIImage(named: "queenW"), UIImage(named: "pawnW")]
        images.forEach { (im) in
            let index = images.firstIndex(of: im)!
            UIView.transition(with: im, duration: 0.2, options: .transitionCrossDissolve, animations: {
                im.image = pieceImages[index]
            }, completion: nil)
        }
    }

    private func showResultView() {
        compressConstraint.priority = .low
        expandedConstraint.priority = .high
        view.layoutIfNeeded()
    }

    private func hideResultView() {
        compressConstraint.priority = .high
        expandedConstraint.priority = .low
        view.layoutIfNeeded()
    }

    @IBAction func closeTapped(_ sender: Any) {
        (self.navigationController as? Navigation)?.pop()
    }

    @IBAction func whiteTapped() {
        guard color == .white else { return }
        whiteButton.layer.borderColor = UIColor.black.withAlphaComponent(0.8).cgColor
        blackButton.layer.borderColor = UIColor.clear.cgColor
        color = .black
        reload()
        animateTransition()
    }

    @IBAction func blackTapped() {
        guard color == .black else { return }
        blackButton.layer.borderColor = UIColor.black.withAlphaComponent(0.8).cgColor
        whiteButton.layer.borderColor = UIColor.clear.cgColor
        color = .white
        reload()
        animateTransition()
    }

    @IBAction func mostTapped() {
        goToGame(mostLabel.opening)
    }

    @IBAction func weakTapped() {
        goToGame(weakLabel.opening)
    }

    @IBAction func strongTapped() {
        goToGame(strongLabel.opening)
    }

    private func goToGame(_ opening: OpeningObject?) {
        guard let opening = opening else { return }
        let gameVC = GameVC((opening, []))
        gameVC.isBlack = color == .white
        (self.navigationController as? Navigation)?.push(gameVC)
    }

    @IBAction func openPlayer() {
        if let playerURL = URL.init(string: "https://lichess.org/@/\(U.shared.searchName)") {
            UIApplication.shared.open(playerURL, options: [:], completionHandler: nil)
        }
    }

}


class OpeningLabel: UILabel {


    var opening: OpeningObject? {
        didSet {
            self.text = opening?.name
        }
    }
}
