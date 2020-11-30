//
//  GameCell.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 20/11/2020.
//

import UIKit

class GameCell: UITableViewCell {

    static let identifier = "GameCell"

    @IBOutlet weak var playersLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var thumbImageview: UIImageView!

    func configure(_ item: GameItem?) {
        guard let item = item else { return }
        playersLabel.text = "\(item.black) - \(item.white)"
        dateLabel.text = item.validDate.readableString()
        switch item.resultForPlayer() {
        case .lose: thumbImageview.tintColor = UIColor.redColor
        case .draw: thumbImageview.tintColor = UIColor.yellowColor
        case .win: thumbImageview.tintColor = UIColor.greenColor
        }
    }
}
