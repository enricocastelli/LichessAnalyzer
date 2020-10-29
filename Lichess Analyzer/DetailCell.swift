//
//  DetailCell.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 22/10/2020.
//

import UIKit

class DetailCell: UITableViewCell {

    static let identifier = "DetailCell"

    @IBOutlet weak var openLabel: UITextView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var thumbImageview: UIImageView!

    func configure(_ item: (CompleteOpening?, [GameItem]?)) {
//        guard let opening = item.0, let games = item.1 else { return }
//        openLabel.text = opening.completeOpening
//        let winPercentage = item.results.filter({$0 == .win}).count.percentageInt(of: item.results.count)
//        percentageLabel.text = winPercentage.description + "%"
//        countLabel.text = item.results.count.description
//        thumbImageview.tintColor = UIColor.percentageColor(Double(winPercentage))
    }
}
