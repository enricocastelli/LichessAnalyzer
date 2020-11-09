//
//  SuggestionVC.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 09/11/2020.
//

import UIKit

class SuggestionVC: UIViewController, ServiceProvider {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    @IBOutlet weak var resultView: ResultView!
    @IBOutlet weak var explanationTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        showLoadingAnimation()
        nameLabel.text = U.shared.searchName
        historyLabel.text = "\(U.shared.account?.username ?? "") against \(U.shared.searchName):"
        getData()
        setSuggestionLabel()
        explanationTextView.delegate = self
        resultView.hideColumn()
    }

    func getData() {
        getVCGames { (games) in
            self.hideLoadingAnimation()
            guard let games = games else { return }
            self.resultView.update(wins: games.lost(), loss: games.wins(), draw: games.draw())
        } failure: { (error) in
            self.hideLoadingAnimation()
        }
    }

    private func setSuggestionLabel() {
        explanationTextView.text = ""
        let total = NSMutableAttributedString(string: "")
        var whiteString = NSMutableAttributedString()
        if let blackS = U.shared.games.findMost(sort: .strongest, using: .black),
           let blackW = U.shared.games.findMost(sort: .weakest, using: .black), blackS != blackW {
            whiteString = NSMutableAttributedString()
                .normal("\n If you use ")
                .bold("white")
                .normal(" pieces, you should start with ")
                .link("\(blackW.name).")
                .normal(" Try to avoid ")
                .link("\(blackS.name).")
        }
        var blackString = NSMutableAttributedString()
        if let whiteS = U.shared.games.findMost(sort: .strongest, using: .white),
           let whiteW = U.shared.games.findMost(sort: .weakest, using: .white), whiteS != whiteW {
            blackString = NSMutableAttributedString()
                .normal("\n If playing ")
                .bold("black")
                .normal(" pieces, you better go with ")
                .link("\(whiteW.name)")
                .normal(" and stay away from ")
                .link("\(whiteS.name).")
        }

        var mostString = NSMutableAttributedString()
        if let whiteM = U.shared.games.findMost(sort: .mostPlayed, using: .white),
           let blackM = U.shared.games.findMost(sort: .mostPlayed, using: .black) {
            mostString = NSMutableAttributedString()
                .bold(U.shared.searchName)
                .normal(" usually plays ")
                .link("\(whiteM.name)")
                .normal(" using ")
                .bold("white")
                .normal(" and ")
                .link("\(blackM.name)")
                .normal(" with ")
                .bold("black.")
        }

        total.append(mostString)
        total.append(whiteString)
        total.append(blackString)
        let paragraphStyle = NSMutableParagraphStyle()
              paragraphStyle.lineSpacing = 8
        let attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: paragraphStyle]
        let range = NSMakeRange(0, total.string.count)
        total.addAttributes(attributes, range: range)
        explanationTextView.attributedText = total
        explanationTextView.textAlignment = .center
    }

    @IBAction func closeTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

}

extension SuggestionVC: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let trimmedUrl = URL.string
            .replacingOccurrences(of: "www.", with: "")
            .replacingOccurrences(of: ".com", with: "")
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of:  "\"", with: "")
            .replacingOccurrences(of:  ".", with: "")
        if let opening = OpeningObject.fromString(trimmedUrl) {
            let gameVC = GameVC((opening, []))
            self.navigationController?.pushViewController(gameVC, animated: true)
        }
        return false
    }
}
