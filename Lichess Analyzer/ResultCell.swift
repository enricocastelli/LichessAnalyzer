//
//  ResultCell.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 21/10/2020.
//

import UIKit

class ResultCell: UITableViewCell {

    static let identifier = "ResultCell"

    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var thumbImageview: UIImageView!

    func configure(_ item: (KnownOpening?, [GameItem]?)) {
        guard let opening = item.0, let games = item.1 else { return }
        openLabel.text = opening.name
        let results = games.map({$0.resultForPlayer()})
        let winPercentage = results.filter({$0 == .win }).count.percentageInt(of: results.count)
        percentageLabel.text = winPercentage.description + "%"
        countLabel.text = results.count.description
        thumbImageview.tintColor = UIColor.percentageColor(Double(winPercentage))
    }
}
