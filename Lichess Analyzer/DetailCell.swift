//
//  DetailCell.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 22/10/2020.
//

import UIKit

class DetailCell: TableViewCell<CompleteOpeningGame> {

    static let identifier: ReuseIdentifier<DetailCell> = ReuseIdentifier(identifier: "DetailCell")

    @IBOutlet weak var openLabel: UITextView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var thumbImageview: UIImageView!

    override func configure(_ item: CompleteOpeningGame) {
        super.configure(item)
        openLabel.text = item.completeOpening
        let winPercentage = item.results.filter({$0 == .win}).count.percentageInt(of: item.results.count)
        percentageLabel.text = winPercentage.description + "%"
        countLabel.text = item.results.count.description
        thumbImageview.tintColor = UIColor.percentageColor(Double(winPercentage))
    }
}
