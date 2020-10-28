//
//  ResultCell.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 21/10/2020.
//

import UIKit

class ResultCell: TableViewCell<OpeningGame> {

    static let identifier: ReuseIdentifier<ResultCell> = ReuseIdentifier(identifier: "ResultCell")

    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var thumbImageview: UIImageView!

    override func configure(_ item: OpeningGame) {
        super.configure(item)
        openLabel.text = item.opening.name
        let winPercentage = item.results.filter({$0 == .win}).count.percentageInt(of: item.results.count)
        percentageLabel.text = winPercentage.description + "%"
        countLabel.text = item.results.count.description
        thumbImageview.tintColor = UIColor.percentageColor(Double(winPercentage))
    }
}
