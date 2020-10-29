//
//  DetailVC.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 22/10/2020.
//

import UIKit

struct DetailItem {

    let opening: KnownOpening
    let win: Int
    let loss: Int
    let draw: Int
}

class DetailVC: ResultVC {

    let item: DetailItem
    let opening: [CompleteOpening: [GameItem]]

    init(_ opening: [CompleteOpening: [GameItem]], item: DetailItem) {
        self.item = item
        self.opening = opening
        super.init(nibName: "ResultVC", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func addObserver() {}

    override func setLabels() {
        titleLabel.text = item.opening.name
        subtitleLabel.text = (item.win + item.loss + item.draw).description + " Games"
    }

    override func reloadData() {
        self.source = opening
        sort(UserData.shared.preferredSorting)
        tableView.reloadData()
    }

    override func setTableView() {
        let rView = ResultView()
        rView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width/1.5)
        tableView.tableHeaderView = rView
        rView.update(wins: item.win, loss: item.loss, draw: item.draw)
        tableView.register(UINib(nibName: ResultCell.identifier, bundle: nil), forCellReuseIdentifier: ResultCell.identifier)
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.pushViewController(GameVC(sections[indexPath.row]), animated: true)
    }
}
